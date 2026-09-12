library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity axi_read is
        generic(WIDTH : integer := 8);
        port(clk: in std_logic;
        rst: in std_logic;
        --// READ ADDRESS CHANNEL
        ar_addr: in std_logic_vector(31 downto 0);
        ar_valid: in std_logic;
        ar_ready: out std_logic;
        --// READ DATA CHANNEL
        r_data: out std_logic_vector(31 downto 0);
        r_resp: out std_logic_vector(1 downto 0);
        r_valid: out std_logic;
        r_ready: in std_logic;
        --// UART MODULE INTERFACE
        uart_read: out std_logic;
        uart_d_out_ser: in std_logic_vector(WIDTH - 1 downto 0);
        uart_full_rx: in std_logic;
        uart_full_tx: in std_logic;
        uart_empty_rx: in std_logic;
        uart_error: in std_logic
        );
end;

architecture synth of axi_read is
    --//
    -- REGISTER MAP
    -- 0x00 <=> RX data out
    -- 0x04 <=> TX data in
    -- 0x08 <=> Control
    -- 0x0C <=> Status
    --//
    signal ar_ready_decode, ar_ready_decode_next, nop_decode, nop_decode_next, stall_load, en_decode, en_load : std_logic;
    signal r_valid_decode, r_valid_load, r_valid_decode_next, r_valid_load_next : std_logic;
    signal addr_load, addr_load_next : unsigned(1 downto 0);
begin
    --//
    -- DECODE Combinational
    --//
    decode_comb : process(all) begin
        if(not rst) then
            ar_ready_decode_next <= '1';
            nop_decode_next <= '1';
            uart_read <= '0';
            r_valid_decode_next <= '0';
            addr_load_next <= (others => '0');
        else
            --//
            -- Default values
            --//
            ar_ready_decode_next <= '1';
            uart_read <= '0';
            nop_decode_next <= '1';
            r_valid_decode_next <= '0';
            addr_load_next <= addr_load;
            if(en_decode) then
                if(ar_valid) then
                    if(ar_ready) then
                        --// Both valid and ready asserted, can transact
                        nop_decode_next <= '0';
                        r_valid_decode_next <= '1';
                        addr_load_next <= unsigned(ar_addr(3 downto 2));
                        if(addr_load_next = 0) then
                            -- RX data out
                            uart_read <= '1';
                        end if;
                    else
                        --// Only valid asserted, assert ready
                        ar_ready_decode_next <= '1';
                    end if;
                end if;
            else
                -- Stage disabled, not ready to receive
                nop_decode_next <= '0';
                ar_ready_decode_next <= '0';
            end if;
        end if;
    end process;
    --//
    -- DECODE clocked
    --//
    decode_clocked : process(clk) begin
        if(rising_edge(clk)) then
            ar_ready_decode <= ar_ready_decode_next;
            nop_decode <= nop_decode_next;
            r_valid_decode <= r_valid_decode_next;
            addr_load <= addr_load_next;
        end if;
    end process;
    --//
    -- LOAD Combinational
    --//
    load_comb : process(all) begin
        if(not rst) then
            stall_load <= '0';
            r_valid_load_next <= '0';
            r_data <= (others => '0');
            r_resp <= (others => '0');
        else
            --//
            -- Default values
            --//
            stall_load <= '0';
            r_valid_load_next <= '0';
            r_data <= (31 downto WIDTH => '0') & uart_d_out_ser;
            r_resp <= "00";
            if(en_load) then
                if(r_valid) then
                    r_valid_load_next <= '1';
                    if(not r_ready) then
                        -- Only r_valid valid, cannot transact
                        stall_load <= '1';
                    end if;
                else
                    stall_load <= '1';
                end if;
                case addr_load is
                    when to_unsigned(0, 2) =>
                        --RX data out
                        r_data <= (31 downto WIDTH => '0') & uart_d_out_ser;
                        r_resp <= "10" when uart_empty_rx else "00";
                        --//SLVERR when RX empty, else OKAY 
                    when to_unsigned(3, 2) =>
                        --Status
                        r_data <= (31 downto 4 => '0') & uart_full_rx & uart_full_tx & uart_empty_rx & uart_error;
                        r_resp <= "00";
                        --//OKAY
                    when others =>
                        r_resp <= "10";
                        --//SLVERR
                end case;
            else
                -- Stage disabled, cannot load
                r_valid_load_next <= '0';
            end if;
        end if;
    end process;
    --//
    -- LOAD Clocked
    --//
    load_clocked : process(clk) begin
        if(rising_edge(clk)) then
            r_valid_load <= r_valid_load_next;
        end if;
    end process;
    --//
    -- Enable signals
    --//
    en_decode <= not stall_load;
    en_load <= not nop_decode;
    --//
    -- Misc.
    --//
    ar_ready <= ar_ready_decode and en_decode;
    r_valid <= r_valid_decode or r_valid_load;
end;