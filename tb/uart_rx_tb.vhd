library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity uart_rx_tb is
    end entity;

architecture rx_test of uart_rx_tb is
    signal clk_tb, rst_tb : std_logic := '0';
    signal sel : std_logic := '1';
    signal d_in_tb : std_logic := '1';
    signal d_out_tb : std_logic_vector(7 downto 0);
    signal error_out : std_logic;
    begin
        dut : entity work.uart_rx generic map(100e6, 8) port map(d_in_rx => d_in_tb, rst => rst_tb, clk => clk_tb, d_out => d_out_tb, error_out => error_out);
        clk_tb <= not clk_tb after 5 ns;
        mainproc: process 
        begin
            wait for 6 ns;
            rst_tb <= '1';
            wait for 10 ns;
            d_in_tb <= '0'; 
            wait for 8.68 us; --start bit
            for i in 1 to 8 loop
                d_in_tb <= not d_in_tb;
                wait for 8.68 us;
            end loop;
            d_in_tb <= '1'; --stop bit
            wait for 8.68 us;
            d_in_tb <= '1';
            wait for 50 ns;
            rst_tb <= '0';
            wait for 6 ns;
            wait;
            --11100110
            end process;
        checkproc:process begin
            wait on d_out_tb;
            if(rst_tb = '1') then
            assert d_out_tb = "01010101"
                report "Mismatch: got " & to_string(d_out_tb) & " expected 01010101"
                severity error;
            end if;
        end process;
    end;