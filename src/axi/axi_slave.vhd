library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.axi_pkg.all;

entity axi_slave is 
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
        uart_write: out std_logic;
        uart_read: out std_logic;
        uart_d_out_ser : in std_logic_vector(WIDTH - 1 downto 0);
        uart_d_in_ser : out std_logic_vector(WIDTH - 1 downto 0);
        uart_full_rx: in std_logic;
        uart_full_tx: in std_logic;
        uart_empty_rx: in std_logic;
        uart_error: in std_logic;
        uart_sel: out std_logic;
        uart_rst: out std_logic
        );
end;

architecture synth of axi_slave is

begin
    --//
    -- REGISTER MAP
    -- 0x00 <=> RX data out
    -- 0x04 <=> TX data in
    -- 0x08 <=> Control
    -- 0x0C <=> Status
    --//
    slave_read:entity work.axi_read
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
            uart_read      => uart_read,
            uart_d_out_ser => uart_d_out_ser,
            uart_full_rx   => uart_full_rx,
            uart_full_tx   => uart_full_tx,
            uart_empty_rx  => uart_empty_rx,
            uart_error     => uart_error
        );
    slave_write:entity work.axi_write
        generic map(
            WIDTH => WIDTH
        )
        port map(
            clk              => clk,
            rst              => rst,
            aw_addr          => aw_addr,
            aw_valid         => aw_valid,
            aw_ready         => aw_ready,
            w_data           => w_data,
            w_valid          => w_valid,
            w_ready          => w_ready,
            rw_resp          => rw_resp,
            rw_valid         => rw_valid,
            rw_ready         => rw_ready,
            uart_write       => uart_write,
            uart_d_in_ser => uart_d_in_ser,
            uart_sel         => uart_sel,
            uart_rst         => uart_rst,
            uart_full_tx   => uart_full_tx
        );
    
    
end;