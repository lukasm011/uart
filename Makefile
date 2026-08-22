VHDLFLAGS = -a --std=08
SRC_DIR = src
TB_DIR = tb
SIM_DIR = sim

TBrx = uart_rx_tb
TBtx = uart_tx_tb
TBtop = uart_top_tb

SRCS = $(addprefix $(SRC_DIR)/, reg.vhd uart_pkg.vhd uart_rx.vhd uart_tx.vhd uart_top.vhd)

final: $(SRCS)
	ghdl $(VHDLFLAGS) --workdir=$(SIM_DIR) $(SRCS) $(TB_DIR)/$(TBrx).vhd $(TB_DIR)/$(TBtx).vhd $(TB_DIR)/$(TBtop).vhd

sim_rx: $(SRCS) $(TB_DIR)/$(TBrx).vhd
	ghdl $(VHDLFLAGS) --workdir=$(SIM_DIR) $(SRCS) $(TB_DIR)/$(TBrx).vhd
	ghdl -e --workdir=$(SIM_DIR) --std=08 $(TBrx)
	ghdl -r --workdir=$(SIM_DIR) --std=08 $(TBrx) --wave=$(SIM_DIR)/uart_rx_tb.ghw --stop-time=100us
	gtkwave $(SIM_DIR)/uart_rx_tb.ghw

sim_tx: $(SRCS) $(TB_DIR)/$(TBtx).vhd
	ghdl $(VHDLFLAGS) --workdir=$(SIM_DIR) $(SRCS) $(TB_DIR)/$(TBtx).vhd
	ghdl -e --workdir=$(SIM_DIR) --std=08 $(TBtx) 
	ghdl -r --workdir=$(SIM_DIR) --std=08 $(TBtx) --wave=$(SIM_DIR)/uart_tx_tb.ghw --stop-time=300us
	gtkwave $(SIM_DIR)/uart_tx_tb.ghw


sim_top: $(SRCS) $(TB_DIR)/$(TBtx).vhd
	ghdl $(VHDLFLAGS) --workdir=$(SIM_DIR) $(SRCS) $(TB_DIR)/$(TBtop).vhd
	ghdl -e --workdir=$(SIM_DIR) --std=08 $(TBtop) 
	ghdl -r --workdir=$(SIM_DIR) --std=08 $(TBtop) --wave=$(SIM_DIR)/uart_top_tb.ghw --stop-time=100us
	gtkwave $(SIM_DIR)/uart_top_tb.ghw

clean:
	rm work-obj08.cf