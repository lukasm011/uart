library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.uart_pkg.all;

entity fifo is
    generic(SLOTS : integer := 8; WIDTH : integer := 8);
    port(clk: in std_logic;
        rst: in std_logic;
        read_i: in std_logic;
        write_i: in std_logic;
        d_in: in std_logic_vector(WIDTH-1 downto 0);
        d_out: out std_logic_vector(WIDTH-1 downto 0);
        full_o: out std_logic;
        empty_o: out std_logic);
end;

architecture synth of fifo is
    signal r_addr, wr_addr, count : unsigned(bits(SLOTS)-1 downto 0);
    signal full_out, empty_out : std_logic;
    type fifo_mem_type is array(0 to SLOTS-1) of std_logic_vector(WIDTH-1 downto 0);
    signal mem: fifo_mem_type;
begin
    process(clk) begin
        if(rising_edge(clk)) then
            if(rst = '0') then
                count <= (others => '0');
                wr_addr <= (others => '0');
                r_addr <= (others => '0');
                d_out <= (others => '0');
            else
            if(write_i = '1' and full_out = '0') then
                --can write
                mem(to_integer(wr_addr)) <= d_in;
                count <= count + 1;
                if(wr_addr < SLOTS - 1) then
                    wr_addr <= wr_addr + 1;
                else
                    --wrap
                    wr_addr <= (others => '0');
                end if;
            end if;
            if(read_i = '1' and empty_out = '0') then
                --can read
                d_out <= mem(to_integer(r_addr));
                count <= count - 1;
                if(r_addr < SLOTS - 1) then
                    r_addr <= r_addr + 1;
                else
                    --wrap
                    r_addr <= (others => '0');
                end if;
            end if;
            end if;
        end if;
    end process;
    full_out <= '1' when count = SLOTS else '0';
    empty_out <= '1' when count = 0 else '0';
    full_o <= full_out;
    empty_o <= empty_out;
end;