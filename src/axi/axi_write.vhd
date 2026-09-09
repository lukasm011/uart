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
    signal data_reg                                                                                                                               : std_logic_vector(WIDTH - 1 downto 0);
    signal addr_load, addr_resp                                                                                                                   : unsigned(1 downto 0);
    signal nop_decode, nop_load, stall_load, stall_resp, en_decode, en_load, en_resp, rw_valid_load, rw_valid_resp : std_logic;
begin
    --//
    -- DECODE
    --//
    --//
    -- The stall flags of LOAD and RESP must be driven combinationally to stop the pipeline from progressing on the next rising edge. 
    --//
    decode_clocked : process(clk)
    begin
        if (rising_edge(clk)) then
            if(not rst) then
                aw_ready <= '1';
                nop_decode <= '1';
                addr_load <= (others => '0');
            else
                --//
                -- Default values
                --//
                aw_ready <= '1';
                if (en_decode) then
                    nop_decode <= '1';
                    if (aw_valid) then
                        --// Stage enabled and address valid
                        if (aw_ready) then
                            --// Both ready and valid active at the same time, can transact
                            nop_decode  <= '0';
                            aw_ready  <= '1';
                            addr_load <= unsigned(aw_addr(3 downto 2));
                        else
                            --// Only valid active, assert ready
                            aw_ready <= '1';
                        end if;
                    end if;
                else
                    aw_ready <= '0';
                end if;
            end if;
        end if;
    end process;
    --//
    -- LOAD Clocked
    --//
    load : process(clk)
    begin
        if (rising_edge(clk)) then
            if(not rst) then
                report("Klipa");
                nop_load <= '1';
                w_ready <= '0';
                rw_valid_load <= '0';
                uart_write <= '0';
                addr_resp <= (others => '0');
                rw_resp <= "00";
            else
                --//
                -- Default values
                --//
                nop_load      <= nop_decode;
                w_ready  <= '1';
                rw_valid_load <= '0';
                uart_write    <= '0';
                if (en_load) then
                    if (w_valid) then
                        report("Here");
                        --// Stage enabled and data valid
                        if (w_ready) then
                            report("Here too");
                            --// Both ready and valid active at the same time, can transact
                            data_reg      <= w_data(WIDTH - 1 downto 0);
                            rw_valid_load <= '1';
                            addr_resp     <= addr_load;
                            --// Set up response
                            case addr_load is
                                when to_unsigned(1, 2) =>
                                    -- TX data in
                                    --//WRITE ONLY
                                    rw_resp    <= "10" when uart_full_tx else "00";
                                    --//SLVERR when TX full, else OKAY
                                    uart_write <= '1';
                                when to_unsigned(2, 2) =>
                                    -- Control
                                    --//WRITE ONLY
                                    rw_resp <= "00";
                                    --//OKAY
                                when others =>
                                    -- Invalid address
                                    rw_resp <= "11";
                                    --//DECERR
                            end case;
                        else
                            --// Only valid active, assert ready
                            w_ready <= '1';
                        end if;
                    else
                        --// Block next stage
                        nop_load <= '1';
                    end if;
                else
                    -- Disabled, cannot transact
                    w_ready <= '0';
                end if;
            end if;
        end if;
    end process;
    --//
    -- LOAD Combinational
    --//
    load_comb : process(all)
    begin
        stall_load <= '0';
        if(en_load) then
            if(not w_valid or not w_ready) then
                stall_load <= '1';
            end if;
        end if;
    end process;
    --//
    -- RESP Clocked
    --//
    resp : process(clk)
    begin
        if (rising_edge(clk)) then
            if(not rst) then
                uart_rst <= '1';
                rw_valid_resp <= '0';
                uart_sel <= '0';
            else
                --//
                -- Default values
                --//
                if (en_resp) then
                    uart_rst <= '1';
                    if (rw_ready) then
                        rw_valid_resp <= '0';
                        if (addr_resp = 2) then
                            -- Control
                            uart_rst <= not data_reg(0);
                            uart_sel <= data_reg(1);
                        end if;
                    end if;
                end if;
            end if;
        end if;
    end process;
    --//
    -- RESP Combinational
    --//
    resp_comb : process(all)
    begin
        stall_resp <= '0';
        if (en_resp and not rw_ready) then
            stall_resp <= '1';
        end if;
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
    rw_valid      <= rw_valid_resp or rw_valid_load;
end;
