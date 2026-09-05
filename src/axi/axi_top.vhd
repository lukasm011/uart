library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity axi_top is
    generic(
        CLK_FREQ : integer := 27_000_000;
        WIDTH : integer := 8;
        DEPTH : integer := 8
    );
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
        --// WRITE ADDRESS CHANNEL
        aw_addr: in std_logic_vector(31 downto 0);
        aw_valid: in std_logic;
        aw_ready: out std_logic;
        --// WRITE DATA CHANNEL
        w_data: in std_logic_vector(31 downto 0);
        w_strb: in std_logic_vector(3 downto 0);
        w_valid: in std_logic;
        w_ready: out std_logic;
        --// WRITE RESPONSE CHANNEL
        rw_resp: out std_logic_vector(1 downto 0);
        rw_valid: out std_logic;
        rw_ready: in std_logic;
        --// UART MODULE INTERFACE
        tx_o : out std_logic;
        rx_i : in std_logic
        );
end;

architecture synth of axi_top is
    signal uart_write, uart_read, uart_full_rx, uart_full_tx, uart_empty_rx,
        uart_error, uart_sel, uart_rst : std_logic;
    signal uart_d_out_ser, uart_d_in_ser : std_logic_vector(WIDTH - 1 downto 0); 
begin
    axi_slave:entity work.axi_slave
        generic map(
            WIDTH => WIDTH
        )
        port map(
            clk            => clk,
            rst            => rst,
            ar_addr        => ar_addr,
            ar_valid       => ar_valid,
            ar_ready       => ar_ready,
            r_data         => r_data,
            r_resp         => r_resp,
            r_valid        => r_valid,
            r_ready        => r_ready,
            aw_addr        => aw_addr,
            aw_valid       => aw_valid,
            aw_ready       => aw_ready,
            w_data         => w_data,
            w_strb         => w_strb,
            w_valid        => w_valid,
            w_ready        => w_ready,
            rw_resp        => rw_resp,
            rw_valid       => rw_valid,
            rw_ready       => rw_ready,
            uart_write     => uart_write,
            uart_read      => uart_read,
            uart_d_out_ser => uart_d_out_ser,
            uart_d_in_ser  => uart_d_in_ser,
            uart_full_rx   => uart_full_rx,
            uart_full_tx   => uart_full_tx,
            uart_empty_rx  => uart_empty_rx,
            uart_error     => uart_error,
            uart_sel       => uart_sel,
            uart_rst       => uart_rst
        );
    uart:entity work.uart_top
        generic map(
            CLK_FREQ => CLK_FREQ,
            WIDTH    => WIDTH,
            DEPTH    => DEPTH
        )
        port map(
            RX_I         => RX_I,
            DATA_IN_SER  => uart_d_in_ser,
            CLK          => CLK,
            RST          => RST,
            RST_RX_I     => uart_rst,
            SEL          => uart_sel,
            READ         => uart_read,
            WRITE        => uart_write,
            ERROR_O      => uart_error,
            DATA_OUT_SER => uart_d_out_ser,
            TX_O         => TX_O,
            FULL_RX_O    => uart_full_rx,
            FULL_TX_O    => uart_full_tx,
            EMPTY_RX_O   => uart_empty_rx
        );
end;