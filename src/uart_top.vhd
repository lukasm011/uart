library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

--//
-- MODULE DESCRIPTION
-- This UART subsystem is able to transmit at 9600baud (slow mode) and 115200baud (fast mode).
-- Selection between the two modes is possible using the sel port.
-- It is also able to receive at baudrates ranging from 4800baud to 1Mbaud.
-- The data to be transmitted is passed to the module via the DATA_IN_SER input and the trigger input must be
-- switched to high for at least one clock cycle to begin the transmission.
-- The data received is written to data_out_ser when the stop bit has been read. If there has been an error during
-- the reading process, error_out will be toggled for one clock cycle, and the rx subsystem will return to idle state.
-- To prevent noise from starting a transmission or causing an error, the input of the rx subsystem is both synchronized
-- and filtered. 
-- Further information provided in readme.
--//


entity uart_top is
    generic(CLK_FREQ : integer := 27000000; WIDTH : integer := 8; DEPTH : integer := 8);
    port(RX_I: in  std_logic;
    DATA_IN_SER: in std_logic_vector(WIDTH-1 downto 0);
    CLK: in std_logic;
    RST: in std_logic;
    RST_RX_I: in std_logic;
    SEL: in std_logic;
    READ: in std_logic;
    WRITE: in std_logic;
    ERROR_O: out std_logic;
    DATA_OUT_SER: out std_logic_vector(WIDTH-1 downto 0);
    TX_O: out std_logic;
    FULL_RX_O: out std_logic;
    FULL_TX_O: out std_logic;
    EMPTY_RX_O: out std_logic
    );
end entity;

architecture top of uart_top is
    signal rst_rx : std_logic;
    begin
        rx : entity work.uart_rx
            generic map(
                CLK_FREQ => CLK_FREQ,
                WIDTH    => WIDTH,
                DEPTH => DEPTH
            )
            port map(
                d_in_rx   => RX_I,
                rst       => rst_rx,
                clk       => CLK,
                d_out     => data_out_ser,
                read      => read,
                error_out => error_o,
                full_o    => FULL_RX_O,
                empty_o   => EMPTY_RX_O
            );
        
        tx: entity work.uart_tx
            generic map(
                CLK_FREQ => CLK_FREQ,
                WIDTH    => WIDTH,
                DEPTH => DEPTH
            )
            port map(
                d_i     => DATA_IN_SER,
                rst     => rst,
                CLK     => CLK,
                sel_i   => sel,
                write_i => write,
                full_o  => FULL_TX_O,
                d_o     => TX_O
            );
        rst_rx <= RST_RX_I and RST;
end;