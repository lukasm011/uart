library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity uart_top is
    generic(CLK_FREQ : integer := 27000000; WIDTH : integer := 8);
    port(rx : in );
end entity;