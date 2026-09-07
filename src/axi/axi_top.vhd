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
        s_axi_araddr: in std_logic_vector(31 downto 0);
        s_axi_arvalid: in std_logic;
        s_axi_arready: out std_logic;
        --// READ DATA CHANNEL
        s_axi_rdata: out std_logic_vector(31 downto 0);
        s_axi_rresp: out std_logic_vector(1 downto 0);
        s_axi_rvalid: out std_logic;
        s_axi_rready: in std_logic;
        --// WRITE ADDRESS CHANNEL
        s_axi_awaddr: in std_logic_vector(31 downto 0);
        s_axi_awvalid: in std_logic;
        s_axi_awready: out std_logic;
        --// WRITE DATA CHANNEL
        s_axi_wdata: in std_logic_vector(31 downto 0);
        --s_axi_wstrb: in std_logic_vector(3 downto 0);
        s_axi_wvalid: in std_logic;
        s_axi_wready: out std_logic;
        --// WRITE RESPONSE CHANNEL
        s_axi_bresp: out std_logic_vector(1 downto 0);
        s_axi_bvalid: out std_logic;
        s_axi_bready: in std_logic;
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
            ar_addr        => s_axi_araddr,
            ar_valid       => s_axi_arvalid,
            ar_ready       => s_axi_arready,
            r_data         => s_axi_rdata,
            r_resp         => s_axi_rresp,
            r_valid        => s_axi_rvalid,
            r_ready        => s_axi_rready,
            aw_addr        => s_axi_awaddr,
            aw_valid       => s_axi_awvalid,
            aw_ready       => s_axi_awready,
            w_data         => s_axi_wdata,
            --w_strb         => s_axi_wstrb,
            w_valid        => s_axi_wvalid,
            w_ready        => s_axi_wready,
            rw_resp        => s_axi_bresp,
            rw_valid       => s_axi_bvalid,
            rw_ready       => s_axi_bready,
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