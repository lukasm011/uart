library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity axi_write is
    generic(WIDTH : integer := 8);
    port(clk           : in  std_logic;
         rst           : in  std_logic;
         --// WRITE ADDRESS CHANNEL
         aw_addr       : in  std_logic_vector(31 downto 0);
         aw_valid      : in  std_logic;
         aw_ready      : out std_logic;
         --// WRITE DATA CHANNEL
         w_data        : in  std_logic_vector(31 downto 0);
         --w_strb: in std_logic_vector(3 downto 0);
         w_valid       : in  std_logic;
         w_ready       : out std_logic;
         --// WRITE RESPONSE CHANNEL
         rw_resp       : out std_logic_vector(1 downto 0);
         rw_valid      : out std_logic;
         rw_ready      : in  std_logic;
         --// UART MODULE INTERFACE
         uart_write    : out std_logic;
         uart_d_in_ser : out std_logic_vector(WIDTH - 1 downto 0);
         uart_sel      : out std_logic;
         uart_rst      : out std_logic;
         uart_full_tx  : in  std_logic
        );
end;

architecture synth of axi_write is
    ------//
    ------ REGISTER MAP
    ------ 0x00 <=> RX data out (READ ONLY)
    ------ 0x04 <=> TX data in (WRITE ONLY)
    ------ 0x08 <=> Control (WRITE ONLY)
    ------ 0x0C <=> Status (READ ONLY)
    ------//
    signal data_reg, data_reg_next                                                                                                : std_logic_vector(WIDTH - 1 downto 0);
    signal addr_load, addr_resp, addr_load_next, addr_resp_next                                                    : unsigned(1 downto 0);
    signal rw_resp_next : std_logic_vector(1 downto 0);
    signal nop_decode, nop_load, stall_load, stall_resp, en_decode, en_load, en_resp, rw_valid_load, rw_valid_resp, w_ready_load : std_logic;
    signal nop_decode_next, nop_load_next, rw_valid_load_next, aw_ready_next, w_ready_load_next, uart_write_next : std_logic;
    signal uart_rst_next, rw_valid_resp_next, uart_sel_next : std_logic;
begin
    --//
    -- DECODE CLOCKED
    --//
    decode_clocked : process(clk)
    begin
        if (rising_edge(clk)) then
            aw_ready <= aw_ready_next;
            nop_decode <= nop_decode_next;
            addr_load <= addr_load_next;
        end if;
    end process;
    --//
    -- DECODE COMBINATIONAL
    --//
    decode_comb : process(all)
    begin
        if (not rst) then
            aw_ready_next <= '1';
            nop_decode_next <= '1';
            addr_load_next <= (others => '0');
        else
            --//
            -- Default values
            --//
            aw_ready_next <= aw_ready;
            nop_decode_next <= '1';
            addr_load_next <= addr_load;
            if(en_decode) then
                if(aw_valid) then
                    if(aw_ready) then
                        --// Both valid and ready active, can transact
                        addr_load_next <= unsigned(aw_addr(3 downto 2));
                        nop_decode_next <= '0';
                    else
                        aw_ready_next <= '1';
                    end if;
                end if;
            else
                aw_ready_next <= '0';
                --//
                -- Do not disable the next stage if current stage is disabled.
                -- If the next stage is the one blocking, disabling it will cause an infinite loop. 
                --//
                nop_decode_next <= '0';
            end if;
        end if;
    end process;
    
    --//
    -- LOAD Combinational
    --//
    load_comb: process(all) begin
        if(not rst) then
            nop_load_next <= '1';
            w_ready_load_next <= '0';
            rw_valid_load_next <= '0';
            uart_write_next <= '0';
            addr_resp_next <= (others => '0');
            stall_load <= '0';
            data_reg_next <= (others => '0');
        else
            --//
            -- Default values
            --//
            nop_load_next <= nop_decode;
            rw_valid_load_next <= '0';
            uart_write_next <= '0';
            addr_resp_next <= addr_resp;
            w_ready_load_next <= w_ready_load;
            stall_load <= '0';
            if(en_load) then
                if(w_valid) then
                    if(w_ready) then
                        --// Both valid and ready active, can transact
                        data_reg_next <= w_data(WIDTH - 1 downto 0);
                        nop_load_next <= '0';
                        rw_valid_load_next <= '1';
                        addr_resp_next <= addr_load;
                        case addr_load is
                            when to_unsigned(1, 2) =>
                                -- TX data in
                                --//WRITE ONLY
                                uart_write_next <= '1';
                                rw_resp_next <= "10" when uart_full_tx else "00";
                                --SLVERR when TX full, else OKAY
                            when to_unsigned(2, 2) =>
                                -- CONTROL
                                --//WRITE ONLY
                                rw_resp_next <= "00";
                            when others =>
                                -- Invalid address, DECERR
                                rw_resp_next <= "11";
                        end case;
                    else
                        --// Only valid active, assert ready
                        w_ready_load_next <= '1';
                        nop_load_next <= '1';
                        stall_load <= '1';
                    end if;
                else
                    --// Data not yet valid, stall
                    nop_load_next <= '1';
                    stall_load <= '1';
                end if;
            else
                --// Stage blocked, do not transact
                w_ready_load_next <= '0';
            end if;
        end if;
    end process;
    --//
    -- LOAD Clocked
    --//
    load : process(clk)
    begin
        if (rising_edge(clk)) then
            data_reg <= data_reg_next;
            nop_load <= nop_load_next;
            rw_valid_load <= rw_valid_load_next;
            uart_write <= uart_write_next;
            addr_resp <= addr_resp_next;
            w_ready_load <= w_ready_load_next;
            rw_resp <= rw_resp_next;
        end if;
    end process;
    --//
    -- RESP Combinational
    --//
    resp_comb : process(all) begin
        if(not rst) then
            uart_sel_next <= '0';
            uart_rst_next <= '1';
            rw_valid_resp_next <= '0';
            stall_resp <= '0';
        else
            --//
            -- Default values
            --//
            uart_sel_next <= uart_sel;
            uart_rst_next <= '1';
            stall_resp <= '0';
            rw_valid_resp_next <= rw_valid_resp;
            if(en_resp) then
                if(rw_valid) then
                    if(rw_ready = '1' and addr_resp = 2) then
                        --TODO: Check whether data_reg can be overwritten in case of a RESP stall
                        uart_rst_next <= not data_reg(0);
                        uart_sel_next <= data_reg(1);
                    end if;
                else
                    -- Set up valid data, stall for one cycle
                    stall_resp <= '1';
                    rw_valid_resp_next <= '1';
                end if;
            else
                -- Not enabled, no response
                rw_valid_resp_next <= '0';
            end if;
        end if;
    end process;
    --//
    -- RESP Clocked
    --//
    resp_clocked : process(clk) begin
        uart_sel <= uart_sel_next;
        uart_rst <= uart_rst_next;
        rw_valid_resp <= rw_valid_resp_next;
    end process;
    --//
    -- ENABLE SIGNALS
    --//
    en_decode     <= stall_load nor stall_resp;
    en_load       <= nop_decode nor stall_resp;
    en_resp       <= not nop_load;
    --//
    -- Misc.
    --//
    uart_d_in_ser <= data_reg;
    w_ready <= w_ready_load and en_load;
    rw_valid      <= rw_valid_resp or rw_valid_load;
end;