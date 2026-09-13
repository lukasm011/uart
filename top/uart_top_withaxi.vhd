library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity uart_top_withaxi is
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
        --data_out_sevseg_o: out std_logic_vector(6 downto 0);
    );
end entity;

architecture synth of uart_top_withaxi is
    --signal data_out_ser : std_logic_vector(7 downto 0);
    --signal data_out_sevseg : std_logic_vector(6 downto 0);
begin
    --//
    -- Designed to work with Sipeed Tang Nano 9K
    -- Clock frequency 27MHz
    --//
    uart: entity work.axi_top
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
            tx_o          => tx_o,
            rx_i          => rx_i
        );
    
    
    --data_out_sevseg_o <= NOT data_out_sevseg;
    --sevseg:process(data_out_ser) begin
    --    case data_out_ser is
    --        when X"30" => data_out_sevseg <= "1000000";
    --        when X"31" => data_out_sevseg <= "1111001";
    --        when X"32" => data_out_sevseg <= "0100100";
    --        when X"33" => data_out_sevseg <= "0110000";
    --        when X"34" => data_out_sevseg <= "0011001";
    --        when X"35" => data_out_sevseg <= "0010010";
    --        when X"36" => data_out_sevseg <= "0000010";
    --        when X"37" => data_out_sevseg <= "1111000";
    --        when X"38" => data_out_sevseg <= "0000000";
    --        when X"39" => data_out_sevseg <= "0010000";
    --        when X"41" => data_out_sevseg <= "0001000";
    --        when X"42" => data_out_sevseg <= "0000011";
    --        when X"43" => data_out_sevseg <= "1000110";
    --        when X"44" => data_out_sevseg <= "0100001";
    --        when X"45" => data_out_sevseg <= "0000110";
    --        when X"46" => data_out_sevseg <= "0001110";
    --        when X"55" => data_out_sevseg <= "0000110";
    --        when others => data_out_sevseg <= "0000000";
    --    end case;
    --end process;
end;
