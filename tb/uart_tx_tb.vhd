library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity uart_tx_tb is
    end entity;

architecture tx_test of uart_tx_tb is
    signal d_in, res : std_logic_vector(7 downto 0);
    signal rst, clk, trig: std_logic := '0';
    signal sel : std_logic := '1';
    signal d_out, error_out : std_logic; 
    begin
        dut: entity work.uart_tx
            generic map(
                CLK_FREQ   => 100e6,
                width => 8
            )
            port map(
                d_in  => d_in,
                rst   => rst,
                clk   => clk,
                sel => sel,
                trig  => trig,
                d_out => d_out
            );
        dut2: entity work.uart_rx
            generic map(
                CLK_FREQ  => 100e6,
                width => 8
            )
            port map(
                d_in  => d_out,
                rst   => rst,
                clk   => clk,
                sel => sel,
                d_out => res,
                error_out => error_out
            );
        
            clk <= not clk after 5 ns;
            mainproc: process begin
                wait for 6 ns;
                rst <= '1';
                d_in <= "11100101";
                wait for 10 ns;
                trig <= '1';
                wait for 10 ns;
                trig <= '0';
                wait for 100 us;
                d_in <= "10000101";
                wait for 5 ns;
                trig <= '1';
                wait for 5 ns;
                trig <= '0';
                wait for 100 us;
                d_in <= "11111101";
                wait for 5 ns;
                trig <= '1';
                wait for 5 ns;
                trig <= '0';
                wait for 2 us;
                wait;
                end process;

        end;