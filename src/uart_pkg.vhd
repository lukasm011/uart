library ieee;
use ieee.std_logic_1164.all;

package uart_pkg is
    function bits(n : integer) return integer;
    type rx_state_type is (IDLE, START_BIT, RECEIVING, STOP_BIT);
    type tx_state_type is (IDLE, START_BIT, TRANSMISSION, STOP_BIT);
    component reg is generic(SIZE : integer := 8); port(d_in : in std_logic_vector(SIZE-1 downto 0);
        clk: in std_logic;
        rst: in std_logic;
        d_out : out std_logic_vector(SIZE-1 downto 0)
        );
    end component;
end package;

package body uart_pkg is
    function bits(n : integer) return integer is
        variable result : integer := 0;
        variable to_check : integer := n;
        begin
            while to_check > 0 loop
                to_check := to_check / 2;
                result := result + 1;
            end loop ;
            return result;
        end function;
end package body;