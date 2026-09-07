library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity axi_top_tb is
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
        s_axi_bready: in std_logic
        );
end;

architecture sim of axi_top_tb is
    signal uart_line : std_logic;
begin
    dut:entity work.axi_top
        generic map(
            CLK_FREQ => 27_000_000,
            WIDTH    => 8,
            DEPTH    => 8
        )
        port map(
            clk           => clk,
            rst           => rst,
            s_axi_araddr  => s_axi_araddr,
            s_axi_arvalid => s_axi_arvalid,
            s_axi_arready => s_axi_arready,
            s_axi_rdata   => s_axi_rdata,
            s_axi_rresp   => s_axi_rresp,
            s_axi_rvalid  => s_axi_rvalid,
            s_axi_rready  => s_axi_rready,
            s_axi_awaddr  => s_axi_awaddr,
            s_axi_awvalid => s_axi_awvalid,
            s_axi_awready => s_axi_awready,
            s_axi_wdata   => s_axi_wdata,
            s_axi_wvalid  => s_axi_wvalid,
            s_axi_wready  => s_axi_wready,
            s_axi_bresp   => s_axi_bresp,
            s_axi_bvalid  => s_axi_bvalid,
            s_axi_bready  => s_axi_bready,
            tx_o          => uart_line,
            rx_i          => uart_line
        );
    

end;