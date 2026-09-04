library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity uart_top_tb is
    end;

architecture sim of uart_top_tb is 
    signal rst, sel : std_logic := '1';
    signal data_in_ser, data_out_ser : std_logic_vector(7 downto 0);
    signal clk, trig, read, write : std_logic := '0';
    signal error_out, tx_out, full_rx_out, full_tx_out, empty : std_logic;
    begin
        dut: entity work.uart_top
            generic map(
                CLK_FREQ => 100e6,
                WIDTH    => 8
            )
            port map(
                RX_I         => tx_out,
                DATA_IN_SER  => DATA_IN_SER,
                CLK          => CLK,
                RST          => RST,
                SEL          => SEL,
                READ         => READ,
                WRITE        => WRITE,
                ERROR_O      => error_out,
                DATA_OUT_SER => DATA_OUT_SER,
                TX_O         => tx_out,
                FULL_RX_O    => full_rx_out,
                FULL_TX_O    => full_tx_out,
                EMPTY_RX_O      => empty
            );
        
        
        clk <= not clk after 5 ns;
        mainproc:process begin
            wait for 1 ns;
            rst <= '0';
            wait for 6 ns;
            rst <= '1';
            data_in_ser <= "01010101";
            write <= '1';
            wait for 10 ns;
            write <= '0';
            data_in_ser <= "11101111";
            wait for 100 us;
            read <= '1';
            write <= '1';
            wait for 10 ns;
            read <= '0';
            write <= '0';
            wait for 100 us;
            read <= '1';
            wait for 10 ns;
            read <= '0';
            wait;
        end process;
        checkproc:process 
            variable counter : integer := 0;
        begin
            wait on data_out_ser;
            if(rst = '1') then
                case counter is
                    when 0 =>
                        assert data_out_ser = "01010101"
                            report "Mismatch! Got " & to_string(data_out_ser) & ". Expected 01010101"
                            severity error;
                        counter := counter + 1;
                    when 1 => 
                        assert data_out_ser = "11101111"
                            report "Mismatch! Got " & to_string(data_out_ser) & ". Expected 11101111"
                            severity error;
                        counter := counter + 1;
                    when others =>
                    end case;
            end if;
        end process;


end;