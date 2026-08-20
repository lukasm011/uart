library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity uart_top is
    generic(CLK_FREQ : integer := 27000000; WIDTH : integer := 8);
    port(rx: in  std_logic;
    data_in: in std_logic_vector(WIDTH-1 downto 0);
    clk: in std_logic;
    rst: in std_logic;
    trig: in std_logic;
    error: out std_logic;
    data_out: std_logic_vector(WIDTH-1 downto 0);
    tx: out std_logic
    );
end entity;