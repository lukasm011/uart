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
        dut : entity work.uart_rx generic map(27e6, 8) port map(d_in => d_in_tb, rst => rst_tb, clk => clk_tb, sel=>sel, d_out => d_out_tb, error_out => error_out);
        clk_tb <= not clk_tb after 5 ns;
        mainproc: process begin
            wait for 6 ns;
            rst_tb <= '1';
            wait for 5 ns;
            d_in_tb <= '0';
            wait for 80 ns; --start bit 
            d_in_tb <= '1';
            wait for 20 ns; --noise
            d_in_tb <= '0';
            wait for 60 ns; --bit 0
            d_in_tb <= '1';
            wait for 320 ns; --bit 1 and 2
            d_in_tb <= '0';
            wait for 320 ns; --bit 3 and 4
            d_in_tb <= '1';
            wait for 640 ns; --bit 5,6,7 and stop bit
            wait for 50 ns;
            wait;
            --11100110
            end process;
    end;