SIM ?= ghdl
TOPLEVEL_LANG ?= vhdl
#COMPILE_ARGS = --std=08
GHDL_ARGS = --std=08
SIM_ARGS = --vcd=coco.vcd --wave=axi_wrte_tb.ghw
VHDL_SOURCES = $(PWD)/../../src/axi/axi_write.vhd
TOPLEVEL = axi_write
MODULE = axi_write_tb
include $(shell cocotb-config --makefiles)/Makefile.sim