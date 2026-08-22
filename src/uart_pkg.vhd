library ieee;
use ieee.std_logic_1164.all;

package uart_pkg is
    function bits(n : integer) return integer;
    type rx_state_type is (IDLE, START_BIT, RECEIVING, STOP_BIT);
    type tx_state_type is (IDLE, START_BIT, TRANSMISSION, STOP_BIT);
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