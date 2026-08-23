library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

--//
-- MODULE DESCRIPTION
-- This UART subsystem is able to transmit at 9600baud (slow mode) and 115200baud (fast mode).
-- Selection between the two modes is possible using the sel port.
-- It is also able to receive at baudrates ranging from 4800baud to 1Mbaud.
-- The data to be transmitted is passed to the module via the data_in_ser input and the trigger input must be
-- switched to high for at least one clock cycle to begin the transmission.
-- The data received is written to data_out_ser when the stop bit has been read. If there has been an error during
-- the reading process, error_out will be toggled for one clock cycle, and the rx subsystem will return to idle state.
-- To prevent noise from starting a transmission or causing an error, the input of the rx subsystem is both synchronized
-- and filtered. 
-- Further information provided in readme.
--//


entity uart_top is
    generic(CLK_FREQ : integer := 27000000; WIDTH : integer := 8);
    port(rx_in: in  std_logic;
    data_in_ser: in std_logic_vector(WIDTH-1 downto 0);
    clk: in std_logic;
    rst: in std_logic;
    sel: in std_logic;
    trig: in std_logic;
    error_out: out std_logic;
    data_out_ser: out std_logic_vector(WIDTH-1 downto 0);
    tx_out: out std_logic
    );
end entity;

architecture top of uart_top is
    begin
        rx : entity work.uart_rx
            generic map(
                CLK_FREQ => CLK_FREQ,
                WIDTH    => WIDTH
            )
            port map(
                d_in_rx   => rx_in,
                rst       => rst,
                clk       => clk,
                d_out     => data_out_ser,
                error_out => error_out
            );
        tx: entity work.uart_tx
            generic map(
                CLK_FREQ => CLK_FREQ,
                WIDTH    => WIDTH
            )
            port map(
                d_in  => data_in_ser,
                rst   => rst,
                clk   => clk,
                sel   => sel,
                trig  => trig,
                d_out => tx_out
            );        
end;