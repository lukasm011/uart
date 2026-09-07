SIM ?= ghdl
TOPLEVEL_LANG ?= vhdl
#COMPILE_ARGS = --std=08
GHDL_ARGS = --std=08
SIM_ARGS = --vcd=coco.vcd --wave=coco.ghw
VHDL_SOURCES = $(PWD)/../../src/uart_pkg.vhd $(PWD)/../../src/axi/axi_pkg.vhd $(PWD)/../../src/fifo.vhd \
$(PWD)/../../src/uart_rx.vhd $(PWD)/../../src/uart_tx.vhd  $(PWD)/../../src/uart_top.vhd $(PWD)/../../src/axi/axi_read.vhd \
$(PWD)/../../src/axi/axi_write.vhd $(PWD)/../../src/axi/axi_slave.vhd $(PWD)/../../src/axi/axi_top.vhd \
$(PWD)/../../tb/axi_top_tb.vhd
TOPLEVEL = axi_top_tb
MODULE = axi_top_coco
include $(shell cocotb-config --makefiles)/Makefile.sim