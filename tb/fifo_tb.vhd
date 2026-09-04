library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity fifo_tb is
end;

architecture sim of fifo_tb is
    signal clk, read_i, write_i : std_logic := '0';
    signal rst : std_logic := '1';
    signal d_in, d_out : std_logic_vector(7 downto 0);
    signal full_o, empty_o : std_logic;
begin
    dut: entity work.fifo
        generic map(
            SLOTS => 8,
            WIDTH => 8
        )
        port map(
            clk     => clk,
            rst     => rst,
            read_i  => read_i,
            write_i => write_i,
            d_in    => d_in,
            d_out   => d_out,
            full_o  => full_o,
            empty_o => empty_o
        );
    clk <= not clk after 5 ns;
    mainproc:process begin
        rst <= '0';
        wait for 6 ns;
        rst <= '1';
        write_i <= '1';
        for i in 0 to 10 loop
            d_in <= std_logic_vector(to_unsigned(i, 8));
            wait for 10 ns;
        end loop;
        assert full_o = '1'
            report "Mismatch! Expected 1. Buffer should be full."
        severity failure;
        write_i <= '0';
        read_i <= '1';
        for i in 0 to 10 loop
            wait for 10 ns;
        end loop;
        assert empty_o = '1'
            report "Mismatch! Expected 1. Buffer should be empty."
        severity failure;
    end process; 
end;