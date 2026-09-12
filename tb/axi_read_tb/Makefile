SIM ?= ghdl
TOPLEVEL_LANG ?= vhdl
#COMPILE_ARGS = --std=08
GHDL_ARGS = --std=08
SIM_ARGS = --wave=axi_read_tb.ghw
VHDL_SOURCES = $(PWD)/../../src/axi/axi_read.vhd
TOPLEVEL = axi_read
MODULE = axi_read_tb
include $(shell cocotb-config --makefiles)/Makefile.sim