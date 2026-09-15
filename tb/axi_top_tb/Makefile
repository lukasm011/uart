SIM ?= ghdl
TOPLEVEL_LANG ?= vhdl
#COMPILE_ARGS = --std=08
GHDL_ARGS = --std=08
SIM_ARGS = --wave=axi_top_tb.ghw
VHDL_SOURCES = $(CURDIR)/../../src/axi/axi_write.vhd $(CURDIR)/../../src/axi/axi_read.vhd $(CURDIR)/../../src/fifo.vhd \
$(CURDIR)/../../src/uart_pkg.vhd $(CURDIR)/../../src/uart_rx.vhd $(CURDIR)/../../src/uart_tx.vhd \
$(CURDIR)/../../src/uart_top.vhd $(CURDIR)/../../src/axi/axi_slave.vhd $(CURDIR)/../../src/axi/axi_top.vhd $(CURDIR)/../axi_top_tb_setup.vhd
TOPLEVEL = axi_top_tb
MODULE = axi_top_tb
include $(shell cocotb-config --makefiles)/Makefile.sim