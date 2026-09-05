library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.axi_pkg.all;

entity axi_read is
        generic(WIDTH : integer := 8);
        port(clk: in std_logic;
        rst: in std_logic;
        --// READ ADDRESS CHANNEL
        ar_addr: in std_logic_vector(31 downto 0);
        ar_valid: in std_logic;
        ar_ready: out std_logic;
        --// READ DATA CHANNEL
        r_data: out std_logic_vector(31 downto 0);
        r_resp: out std_logic_vector(1 downto 0);
        r_valid: out std_logic;
        r_ready: in std_logic;
        --// UART MODULE INTERFACE
        uart_read: out std_logic;
        uart_d_out_ser: in std_logic_vector(WIDTH - 1 downto 0);
        uart_full_rx: in std_logic;
        uart_full_tx: in std_logic;
        uart_empty_rx: in std_logic;
        uart_error: in std_logic
        );
end;

architecture synth of axi_read is
    ------//
    ------ REGISTER MAP
    ------ 0x00 <=> RX data out (READ ONLY)
    ------ 0x04 <=> TX data in (WRITE ONLY)
    ------ 0x08 <=> Control (WRITE ONLY)
    ------ 0x0C <=> Status (READ ONLY)
    ------//
    type axi_read_mem_type is array(0 to 3) of std_logic_vector(WIDTH-1 downto 0);
    signal state, next_state : axi_read_state_type;
    signal r_data_sig, next_r_data : std_logic_vector(31 downto 0);
    signal addr, next_addr : unsigned(1 downto 0);
    signal registers, next_registers : axi_read_mem_type;
    signal next_uart_read, next_r_valid,
        next_ar_ready : std_logic;
    signal next_r_resp : std_logic_vector(1 downto 0);
begin

    next_state_proc:process(all) begin
        next_state <= state;
        if(rst) then
            next_state <= IDLE;
        else
            case state is
                when IDLE =>
                    if(ar_valid) then
                        next_state <= DECODE_1;
                    end if;
                when DECODE_1 =>
                    if(addr = 0) then
                        next_state <= DECODE_2;
                    else
                        next_state <= DATA;
                    end if;
                when DECODE_2 =>
                    next_state <= DATA;
                when DATA =>
                    if(r_ready) then
                        next_state <= IDLE;
                    end if;
            end case;
        end if;
    end process;

    data_state_regs:process(clk) begin
        if(rising_edge(clk)) then
            registers <= next_registers;
            addr <= next_addr;
            state <= next_state;
            uart_read <= next_uart_read;
            r_valid <= next_r_valid;
            ar_ready <= next_ar_ready;
            r_data_sig <= next_r_data;
            r_resp <= next_r_resp;
        end if;
    end process;

    datapath:process(all) begin
        case state is
            when IDLE =>
                if(ar_valid) then
                    next_ar_ready <= '1';
                    next_addr <= unsigned(ar_addr(3 downto 2));
                end if;
            when DECODE_1 =>
                case addr is
                    when 0 =>
                        --RX data out
                        next_uart_read <= '1';
                    when 1 =>
                        --TX data in
                        --// WRITE ONLY, NO READING.
                        next_r_valid <= '1';
                        next_r_resp <= "11";
                        --//DECERR
                    when 2 =>
                        --Control
                        --// WRITE ONLY, NO READING.
                        next_r_valid <= '1';
                        next_r_resp <= "11";
                        --//DECERR
                    when 3 =>
                        --Status
                        next_registers(integer(addr)) <= (WIDTH-1 downto 4 => '0') & uart_full_rx & 
                        uart_full_tx & uart_empty_rx & uart_error;
                        next_r_valid <= '1';
                        next_r_resp <= "00";
                end case;
            when DECODE_2 =>
                --RX data out
                next_registers(integer(addr)) <= uart_d_out_ser;
                next_r_valid <= '1';
                next_r_resp <= "10" when uart_empty_rx else "00";
            when DATA =>
                next_r_data <= (31 downto WIDTH => '0') & registers (integer(addr));
                next_r_valid <= not r_ready;
        end case;
    end process;
    r_data <= r_data_sig;
end;