library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity uart_top_sevseg is
    port(RX_I: in  std_logic;
    RST_RX_I : in std_logic;
    DATA_IN_SER: in std_logic_vector(8-1 downto 0);
    DATA_OUT_SER: out std_logic_vector(8-1 downto 0);
    CLK: in std_logic;
    RST: in std_logic;
    SEL: in std_logic;
    READ: in std_logic;
    WRITE: in std_logic;
    FULL_RX_O: out std_logic;
    EMPTY_RX_O: out std_logic;
    FULL_TX_O: out std_logic;
    ERROR_O: out std_logic;
    --data_out_sevseg_o: out std_logic_vector(6 downto 0);
    TX_O: out std_logic
    );
end entity;

architecture synth of uart_top_sevseg is
    --signal data_out_ser : std_logic_vector(7 downto 0);
    --signal data_out_sevseg : std_logic_vector(6 downto 0);
begin
    --//
    -- Designed to work with Sipeed Tang Nano 9K
    -- Clock frequency 27MHz
    --//
    uart: entity work.uart_top
        generic map(
            CLK_FREQ => 27_000_000,
            WIDTH    => 8,
            DEPTH    => 8
        )
        port map(
            RX_I         => RX_I,
            DATA_IN_SER  => DATA_IN_SER,
            CLK          => CLK,
            RST          => RST,
            RST_RX_I     => RST_RX_I,
            SEL          => SEL,
            READ         => READ,
            WRITE        => WRITE,
            ERROR_O      => ERROR_O,
            DATA_OUT_SER => DATA_OUT_SER,
            TX_O         => TX_O,
            FULL_RX_O    => FULL_RX_O,
            FULL_TX_O    => FULL_TX_O,
            EMPTY_RX_O   => EMPTY_RX_O
        );
    

    --data_out_sevseg_o <= NOT data_out_sevseg;
    --sevseg:process(data_out_ser) begin
    --    case data_out_ser is
    --        when X"30" => data_out_sevseg <= "1000000";
    --        when X"31" => data_out_sevseg <= "1111001";
    --        when X"32" => data_out_sevseg <= "0100100";
    --        when X"33" => data_out_sevseg <= "0110000";
    --        when X"34" => data_out_sevseg <= "0011001";
    --        when X"35" => data_out_sevseg <= "0010010";
    --        when X"36" => data_out_sevseg <= "0000010";
    --        when X"37" => data_out_sevseg <= "1111000";
    --        when X"38" => data_out_sevseg <= "0000000";
    --        when X"39" => data_out_sevseg <= "0010000";
    --        when X"41" => data_out_sevseg <= "0001000";
    --        when X"42" => data_out_sevseg <= "0000011";
    --        when X"43" => data_out_sevseg <= "1000110";
    --        when X"44" => data_out_sevseg <= "0100001";
    --        when X"45" => data_out_sevseg <= "0000110";
    --        when X"46" => data_out_sevseg <= "0001110";
    --        when X"55" => data_out_sevseg <= "0000110";
    --        when others => data_out_sevseg <= "0000000";
    --    end case;
    --end process;
end;