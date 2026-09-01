library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity uart_top_sevseg is
    port(rx_in: in  std_logic;
    data_in_ser: in std_logic_vector(8-1 downto 0);
    clk: in std_logic;
    rst: in std_logic;
    sel: in std_logic;
    trig: in std_logic;
    error_out: out std_logic;
    data_out_sevseg_o: out std_logic_vector(6 downto 0);
    tx_out: out std_logic
    );
end entity;

architecture synth of uart_top_sevseg is
    signal data_out_ser : std_logic_vector(7 downto 0);
    signal data_out_sevseg : std_logic_vector(6 downto 0);
begin
    --//
    -- Designed to work with Sipeed Tang Nano 9K
    -- Clock frequency 27MHz
    --//
    uart: entity work.uart_top
        generic map(
            CLK_FREQ => 27_000_000,
            WIDTH    => 8
        )
        port map(
            rx_in        => rx_in,
            data_in_ser  => data_in_ser,
            clk          => clk,
            rst          => rst,
            sel          => sel,
            trig         => trig,
            error_out    => error_out,
            data_out_ser => data_out_ser,
            tx_out       => tx_out
        );

    data_out_sevseg_o <= NOT data_out_sevseg;
    sevseg:process(data_out_ser) begin
        case data_out_ser is
            when X"30" => data_out_sevseg <= "1000000";
            when X"31" => data_out_sevseg <= "1111001";
            when X"32" => data_out_sevseg <= "0100100";
            when X"33" => data_out_sevseg <= "0110000";
            when X"34" => data_out_sevseg <= "0011001";
            when X"35" => data_out_sevseg <= "0010010";
            when X"36" => data_out_sevseg <= "0000010";
            when X"37" => data_out_sevseg <= "1111000";
            when X"38" => data_out_sevseg <= "0000000";
            when X"39" => data_out_sevseg <= "0010000";
            when X"41" => data_out_sevseg <= "0001000";
            when X"42" => data_out_sevseg <= "0000011";
            when X"43" => data_out_sevseg <= "1000110";
            when X"44" => data_out_sevseg <= "0100001";
            when X"45" => data_out_sevseg <= "0000110";
            when X"46" => data_out_sevseg <= "0001110";
            when X"55" => data_out_sevseg <= "0000110";
            when others => data_out_sevseg <= "0000000";
        end case;
    end process;
end;
