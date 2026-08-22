library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.uart_pkg.all;

entity uart_rx is
    generic(CLK_FREQ : integer := 27000000; WIDTH : integer := 8);
    port(d_in_rx : in std_logic;
    rst : in std_logic;
    clk : in std_logic;
    sel : in std_logic;
    d_out : out std_logic_vector(WIDTH-1 downto 0);
    error_out : out std_logic
    );
end uart_rx;

architecture synth of uart_rx is
    --Designed merely for 9600baud (slow mode) and 115200baud (fast mode)
    signal BAUD_RATE, NEXT_BAUD_RATE : integer;
    signal CPB, NEXT_CPB : integer;
    constant counter_width : integer := bits(CLK_FREQ/9600 - 1);
    --worst case is largest oversampling rate with rate of 9600baud
    constant bit_counter_width : integer := bits(WIDTH);
    signal state, next_state : rx_state_type := IDLE;
    signal counter, next_counter : UNSIGNED(counter_width-1 downto 0);
    signal bit_counter, next_bit_counter : UNSIGNED(bit_counter_width-1 downto 0);
    signal d_in_last, error_sig, next_error, d_in : std_logic;
    signal buf, next_buf, next_d_out, d_out_sig : std_logic_vector(WIDTH-1 downto 0);
    signal d_in_sync : std_logic_vector(1 downto 0);
    signal d_in_filter : unsigned(1 downto 0);
    begin
        next_state_logic:process(all) begin 
            if(rst = '0') then
                next_state <= IDLE;
            else
            next_state <= state;
            case state is
                when IDLE => 
                    if(d_in = '0' and d_in_last = '1') then
                        next_state <= START_BIT;
                    end if;
                when START_BIT =>
                    if(counter = CPB / 2 - 1) then
                        if(d_in = '1') then
                            --invalid value during start sequence
                            next_state <= IDLE;
                        else
                            next_state <= RECEIVING;
                        end if;
                    end if;
                when RECEIVING =>
                    if(bit_counter = WIDTH-1 and counter = CPB-1) then
                        next_state <= STOP_BIT;
                    end if;
                when STOP_BIT =>
                    if(counter = CPB-1) then
                        --no need for invalid value handling, 
                        --next state would still be idle
                        next_state <= IDLE;
                    end if;
            end case;
            end if;
        end process;

        state_data_regs:process(clk) begin
            if rising_edge(clk) then
                d_in_last <= d_in;
                state <= next_state;
                counter <= next_counter;
                bit_counter <= next_bit_counter;
                buf <= next_buf;
                CPB <= NEXT_CPB;
                BAUD_RATE <= NEXT_BAUD_RATE;
                error_sig <= next_error;
                d_out_sig <= next_d_out;
            end if;
        end process;
        
        datapath:process(all) begin
            if(rst = '0') then
                next_counter <= (next_counter'range => '0');
                next_bit_counter <= (next_bit_counter'range => '0');
                next_buf <= (next_buf'range => '0');
                next_d_out <= (d_out'range => '0');
                next_error <= '0';
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
            next_error <= error_sig;
            next_d_out <= d_out_sig;
            case state is
                when IDLE =>
                    if(d_in = '0') then
                        --start bit detected, lock CPB
                        NEXT_CPB <= CLK_FREQ / BAUD_RATE;
                    end if;
                    NEXT_BAUD_RATE <= 115200 when sel = '1' else 9600;
                    --baud rate can only be set when idle
                    next_error <= '0';
                when START_BIT =>
                    if(counter = CPB / 2 - 1) then
                        --reached middle of start bit
                        if(d_in = '1') then
                            --invalid value during start sequence
                            next_error <= '1';
                        end if;
                        next_counter <= TO_UNSIGNED(0, counter_width);
                    else
                        next_counter <= counter + 1;
                    end if;
                when RECEIVING =>
                    if(counter = CPB-1) then
                        --reached middle of data bit
                        next_counter <= TO_UNSIGNED(0, counter_width);
                        next_bit_counter <= bit_counter + 1;
                        --insert data bit and shift right
                        next_buf <= d_in & buf(WIDTH-1 downto 1);
                    else
                        next_counter <= counter + 1;
                    end if;
                when STOP_BIT =>
                    if(counter = CPB-1) then
                        --reached middle of stop bit
                        next_counter <= TO_UNSIGNED(0, counter_width);
                        next_bit_counter <= TO_UNSIGNED(0, bit_counter_width);
                        if(d_in = '1') then
                            --change output
                            next_d_out <= buf;
                        else
                            --invalid value during stop sequence
                            next_error <= '1';
                        end if;
                    else
                        next_counter <= counter + 1;
                    end if;
            end case;
            end if;
            error_out <= error_sig;
            d_out <= d_out_sig;
        end process;
    --//
    -- Synchronization and filtering:
    -- The d_in_rx value is buffered through a two stage synchronizer to prevent metastability issues.
    -- A filter is applied by keeping track of the last few states through a counter which is incremented
    -- in case a '1' is read, and decremented in case a '0' is read. It does, however, have a maximum value of 3
    -- and a minimum value of 0. Thus, to change the state of a value that was stable for a long time, the value
    -- has to be different for at least 3 clock cycles. This prevents noise from falsely initiating a start bit or
    -- causing an error.
    --//
    synchronizer:process(clk) begin
        if(rising_edge(clk)) then
            --default value
            if(rst = '0') then
                d_in_filter <= (others => '1');
                d_in_sync <= (others => '1');
                d_in <= '1';
            else
                d_in_sync(1) <= d_in_sync(0);
                d_in_sync(0) <= d_in_rx;
                if(d_in_sync(1) = '1' and d_in_filter < 3) then
                    d_in_filter <= d_in_filter + 1;
                elsif(d_in_sync(1) = '0' and d_in_filter > 0) then
                    d_in_filter <= d_in_filter - 1;
                end if;
                d_in <= '1' when d_in_filter = 3 else '0' when d_in_filter = 0 else d_in;
            end if;
        end if;
    end process;
    end architecture;