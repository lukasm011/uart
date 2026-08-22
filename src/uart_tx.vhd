library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.uart_pkg.all;

entity uart_tx is
    generic(CLK_FREQ : integer := 27000000; WIDTH : integer := 8);
    port(d_in : in std_logic_vector(WIDTH - 1 downto 0);
    rst : in std_logic;
    clk : in std_logic;
    sel : in std_logic;
    trig : in std_logic;
    d_out : out std_logic
    );
end entity;

architecture synth of uart_tx is
    --declarations
    signal CPB, NEXT_CPB : integer;
    signal BAUD_RATE, NEXT_BAUD_RATE : integer;
    constant counter_width : integer := bits(CLK_FREQ/9600 - 1);
    --worst case is highest oversampling rate with 9600baud
    constant bit_counter_width : integer := bits(WIDTH-1);
    signal state, next_state : tx_state_type := IDLE;
    signal counter, next_counter : unsigned(counter_width-1 downto 0) := (others=>'0');
    signal bit_counter, next_bit_counter : unsigned(bit_counter_width-1 downto 0);
    signal next_d_out, d_out_sig : std_logic;
    signal buf, next_buf : std_logic_vector(WIDTH-1 downto 0);
    begin
        next_state_proc: process(all) begin
            next_state <= state;
            case state is
                when IDLE =>
                    if(trig = '1') then
                        --transmission requested
                        next_state <= START_BIT;
                    end if;
                when START_BIT =>
                    if(counter = CPB - 1) then
                        next_state <= TRANSMISSION;
                    end if;
                when TRANSMISSION =>
                    if(counter = CPB - 1 and bit_counter = WIDTH-1) then
                        --transmitted final bit
                        next_state <= STOP_BIT;
                    end if;
                when STOP_BIT =>
                    if(counter = CPB - 1) then
                        next_state <= IDLE;
                    end if;
                end case;
                if(rst = '0') then
                    next_state <= IDLE;
                end if;
            end process;
        state_data_regs:process(clk) begin
            if(rising_edge(clk)) then
                state <= next_state;
                counter <= next_counter;
                bit_counter <= next_bit_counter;
                d_out_sig <= next_d_out;
                buf <= next_buf;
                BAUD_RATE <= NEXT_BAUD_RATE;
                CPB <= NEXT_CPB;
            end if;
            end process;
        datapath:process(all) begin
            if(rst = '0') then
                next_bit_counter <= TO_UNSIGNED(0, bit_counter_width);
                next_counter <= TO_UNSIGNED(0, counter_width);
                next_d_out <= '1';
                next_buf <= (next_buf'range => '0');
                --//
                --on reset, slow mode (9600baud) is automatically selected
                --real value will be selected when state becomes idle
                --//
                NEXT_BAUD_RATE <= 9600;
                NEXT_CPB <= CLK_FREQ / 9600;
            else
            --//
            --default values
            --//
                NEXT_BAUD_RATE <= BAUD_RATE;
                NEXT_CPB <= CPB;
                next_counter <= counter;
                next_bit_counter <= bit_counter;
                next_buf <= buf;
                next_d_out <= d_out_sig;
                case state is
                    when IDLE =>
                        if(trig = '1') then
                            --transmission requested, lock in buffer and cpb
                            next_d_out <= '0';
                            next_buf <= d_in;
                            NEXT_CPB <= CLK_FREQ / BAUD_RATE;
                        end if;
                        NEXT_BAUD_RATE <= 115200 when sel = '1' else 9600;
                    when START_BIT =>
                        if(counter = CPB - 1) then
                            --completed start bit sequence
                            next_counter <= TO_UNSIGNED(0, counter_width);
                            --output lowest bit and shift right
                            next_d_out <= buf(0);
                            next_buf <= '0' & buf(WIDTH-1 downto 1);
                        else
                            next_counter <= counter + 1;
                        end if;
                    when TRANSMISSION =>
                        if(counter = CPB - 1) then
                            --output lowest bit when resuming transmission,
                            --begin stop sequence when end reached
                            next_d_out <= buf(0) when bit_counter /= WIDTH - 1 else '1';
                            next_buf <= '0' & buf(WIDTH-1 downto 1);
                            next_bit_counter <= bit_counter + 1;
                            next_counter <= TO_UNSIGNED(0, counter_width);
                        else
                            next_counter <= counter + 1;
                        end if;
                    when STOP_BIT =>
                        if(counter = CPB - 1) then
                            next_bit_counter <= TO_UNSIGNED(0, bit_counter_width);
                            next_counter <= TO_UNSIGNED(0, counter_width);
                        else
                            next_counter <= counter + 1;
                        end if;
                end case;
            end if;
            d_out <= d_out_sig;
        end process;
end architecture;