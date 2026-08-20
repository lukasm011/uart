VHDLFLAGS = -a --std=08
SRC_DIR = src
TB_DIR = tb
SIM_DIR = sim

TBrx = uart_rx_tb
TBtx = uart_tx_tb

SRCS = $(addprefix $(SRC_DIR)/, reg.vhd uart_pkg.vhd uart_rx.vhd uart_tx.vhd)

final: $(SRCS)
	ghdl $(VHDLFLAGS) --workdir=$(SIM_DIR) $(SRCS) $(TB_DIR)/$(TBrx) $(TB_DIR)/$(TBtx)

sim_rx: uart_rx.vhd uart_pkg.vhd reg.vhd $(TBrx).vhd
	ghdl $(VHDLFLAGS) --workdir=$(SIM_DIR) $(SRCS) $(TB_DIR)/$(TBrx).vhd
	ghdl -e --std=08 $(TBrx)
	ghdl -r --std=08 $(TBrx) --wave=uart_rx_tb.ghw --stop-time=2000ns

sim_tx: $(SRCS) $(TB_DIR)/$(TBtx).vhd
	ghdl $(VHDLFLAGS) --workdir=$(SIM_DIR) $(SRCS) $(TB_DIR)/$(TBtx).vhd
	ghdl -e --workdir=$(SIM_DIR) --std=08 $(TBtx) 
	ghdl -r --workdir=$(SIM_DIR) --std=08 $(TBtx) --wave=$(SIM_DIR)/uart_tx_tb.ghw --stop-time=300us
	gtkwave $(SIM_DIR)/uart_tx_tb.ghw

clean:
	rm work-obj08.cf