library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.axi_pkg.all;


entity axi_write is
    generic(WIDTH : integer := 8);
    port(clk: in std_logic;
        rst: in std_logic;
        --// WRITE ADDRESS CHANNEL
        aw_addr: in std_logic_vector(31 downto 0);
        aw_valid: in std_logic;
        aw_ready: out std_logic;
        --// WRITE DATA CHANNEL
        w_data: in std_logic_vector(31 downto 0);
        --w_strb: in std_logic_vector(3 downto 0);
        w_valid: in std_logic;
        w_ready: out std_logic;
        --// WRITE RESPONSE CHANNEL
        rw_resp: out std_logic_vector(1 downto 0);
        rw_valid: out std_logic;
        rw_ready: in std_logic;
        --// UART MODULE INTERFACE
        uart_write: out std_logic;
        uart_d_in_ser: out std_logic_vector(WIDTH - 1 downto 0);
        uart_sel: out std_logic;
        uart_rst: out std_logic;
        uart_full_tx: in std_logic
        );
end;

architecture synth of axi_write is
    ------//
    ------ REGISTER MAP
    ------ 0x00 <=> RX data out (READ ONLY)
    ------ 0x04 <=> TX data in (WRITE ONLY)
    ------ 0x08 <=> Control (WRITE ONLY)
    ------ 0x0C <=> Status (READ ONLY)
    ------//
    type axi_write_mem_type is array(0 to 3) of std_logic_vector(WIDTH-1 downto 0);
    signal registers, next_registers : axi_write_mem_type;
    signal addr, next_addr : unsigned(1 downto 0);
    signal state, next_state : axi_write_state_type;
    signal next_aw_ready, next_uart_write, next_uart_sel,
        next_uart_rst, next_rw_valid, next_w_ready : std_logic;
    signal next_uart_d_in_ser : std_logic_vector(WIDTH - 1 downto 0);
    signal next_rw_resp : std_logic_vector(1 downto 0);
begin

    next_state_proc:process(all) begin
        if(rst) then
            next_state <= IDLE;
        else
            next_state <= state;
            case state is
                when IDLE =>
                    if(aw_valid) then
                        next_state <= DECODE;
                    end if;
                when DECODE =>
                    if(w_valid) then
                        next_state <= DATA;
                    end if;
                when DATA =>
                    next_state <= RESP;
                when RESP =>
                    if(rw_ready) then
                        next_state <= IDLE;
                    end if;
            end case;
        end if;
    end process;

    state_data_regs:process(clk) begin
        if(rising_edge(clk)) then
            aw_ready <= next_aw_ready;
            w_ready <= next_w_ready;
            rw_resp <= next_rw_resp;
            rw_valid <= next_rw_valid;
            uart_write <= next_uart_write;
            uart_sel <= next_uart_sel;
            uart_rst <= next_uart_rst;
            state <= next_state;
            addr <= next_addr;
            registers <= next_registers;
            uart_d_in_ser <= next_uart_d_in_ser;
        end if;
    end process;

    datapath:process(all) begin
        --//
        -- Default values
        --//
        next_aw_ready <= aw_ready;
        next_w_ready <= w_ready;
        next_rw_resp <= rw_resp;
        next_rw_valid <= rw_valid;
        next_uart_write <= uart_write;
        next_uart_sel <= uart_sel;
        next_uart_rst <= uart_rst;
        next_addr <= addr;
        next_registers <= registers;
        next_uart_d_in_ser <= uart_d_in_ser;
        case state is
            when IDLE =>
                if(aw_valid) then
                    next_aw_ready <= '1';
                    next_addr <= unsigned(aw_addr(3 downto 2));
                end if;
            when DECODE =>
                if(w_valid) then
                    next_w_ready <= '1';
                    case addr is
                        when 0 =>
                            --RX data out
                            --// READ ONLY
                        when 1 =>
                            --TX data in
                            --// WRITE ONLY
                            next_registers(integer(addr)) <= w_data(WIDTH - 1 downto 0);
                        when 2 =>
                            --Control
                            --// WRITE ONLY
                            next_registers(integer(addr)) <= w_data(WIDTH - 1 downto 0);
                        when 3 =>
                            --Status
                            --// READ ONLY
                    end case;
                end if;
            when DATA =>
                next_rw_valid <= '1';
                case addr is
                    when 0 =>
                        --RX data out
                        --//READ ONLY
                        next_rw_resp <= "11";
                        --//DECERR
                    when 1 =>
                        --TX data in
                        --//WRITE ONLY
                        next_rw_resp <= "10" when uart_full_tx else "00";
                        --//SLVERR when TX full, else OKAY
                        next_uart_write <= '1';
                        next_uart_d_in_ser <= registers(integer(addr));
                    when 2 =>
                        --Control
                        --//WRITE ONLY
                        next_rw_resp <= "00"; 
                        --//OKAY
                        next_uart_rst <= registers(integer(addr))(0);
                        next_uart_sel <= registers(integer(addr))(0);
                    when 3 =>
                        --Status
                        --//READ ONLY
                        next_rw_resp <= "11";
                        --//DECERR
                end case;
            when RESP =>
                next_rw_valid <= not rw_ready;
        end case;
        if(rst) then
            next_aw_ready <= '0';
            next_w_ready <= '0';
            next_rw_resp <= "00";
            next_rw_valid <= '0';
            next_uart_write <= '0';
            next_uart_sel <= '0';
            next_uart_rst <= '0';
            next_addr <= "00";
            for i in 0 to 3 loop
                registers(i) <= (others => '0');
            end loop;
            next_uart_d_in_ser;
        end if;
    end process;
end;