library ieee;
use ieee.std_logic_1164.all;

entity reg is 
    generic(SIZE : integer := 8);
    port(d_in : in std_logic_vector(SIZE-1 downto 0);
        clk: in std_logic;
        rst: in std_logic;
        d_out : out std_logic_vector(SIZE-1 downto 0)
        );
end entity;

architecture synth of reg is 
    begin
        process(clk) begin
            if(rising_edge(clk)) then
                if(rst = '1') then
                    d_out <= d_in;
                else
                    d_out <= (d_out'range => '0');
                end if;
            end if;
        end process;
    end;