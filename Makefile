VHDLFLAGS = -a --std=08
SRC_DIR = src
TB_DIR = tb
SIM_DIR = sim
TOP_DIR = top

TBrx = uart_rx_tb
TBtx = uart_tx_tb
TBtop = uart_top_tb

SRCS = $(addprefix $(SRC_DIR)/, uart_pkg.vhd fifo.vhd uart_rx.vhd uart_tx.vhd) #RETURN uart_top here

export GHDL_PREFIX=/usr/lib/ghdl/mcode/vhdl

.PHONY: final sim_rx sim_tx sim_top clean

final: $(SRCS) $(TOP_DIR)/uart_top_sevseg.vhd
	yosys -m ghdl -p 'ghdl --std=08 $(SRCS) top/uart_top_sevseg.vhd -e uart_top_sevseg; synth_gowin -json top/design.json'
	nextpnr-gowin --json top/design.json --write top/uart_pnr.json --device GW1NR-LV9QN88PC6/I5 --family GW1N-9C --cst top/tangnano9k.cst
	gowin_pack -d GW1N-9C -o top/uart.fs top/uart_pnr.json
	openFPGALoader -b tangnano9k top/uart.fs

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

sim_top: $(SRCS) $(TB_DIR)/$(TBtop).vhd
	ghdl $(VHDLFLAGS) --workdir=$(SIM_DIR) $(SRCS) $(TB_DIR)/$(TBtop).vhd
	ghdl -e --workdir=$(SIM_DIR) --std=08 $(TBtop) 
	ghdl -r --workdir=$(SIM_DIR) --std=08 $(TBtop) --wave=$(SIM_DIR)/uart_top_tb.ghw --stop-time=200us
	gtkwave $(SIM_DIR)/uart_top_tb.ghw

clean:
	rm -f top/*.json
	rm -f top/*.fs
	rm -f sim/*.ghw
	rm -f sim/*.cf