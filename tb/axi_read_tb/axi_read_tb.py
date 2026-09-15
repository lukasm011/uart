import cocotb;
from cocotb.triggers import RisingEdge, ClockCycles, Timer
from cocotb.clock import Clock
from cocotbext.axi import AxiLiteBus, AxiLiteMaster, AxiLiteReadBus

period_clk = 10**-8

async def wait_pre_sample():
    await Timer(1, unit = "ns")

@cocotb.test
async def axi_read_test(dut):
    #############################################################################################################
        # TEST 1: Stalling
        # Tests whether a late R_READY input can safely stall and prevent a transaction from happening on the AW bus.
    #############################################################################################################
    # Reset read slave
    clk = Clock(dut.clk, 10, unit = "ns")
    cocotb.start_soon(clk.start())
    dut.rst.value = 0
    await ClockCycles(dut.clk, 2)
    dut.rst.value = 1
    # Set up busses
    dut.ar_addr.value = 0xC #STATUS
    dut.ar_valid.value = 1
    dut.r_ready.value = 0
    dut.uart_d_out_ser.value = 0
    dut.uart_full_rx.value = 1
    dut.uart_full_tx.value = 1
    dut.uart_empty_rx.value = 0
    dut.uart_error.value = 1
    #############################
    await RisingEdge(dut.clk)
    # AR Handshake
    # Keep r_ready low
    await wait_pre_sample()
    assert dut.addr_load.value == 3, "Address not loaded despite handshake"
    #############################
    await RisingEdge(dut.clk)
    # LOAD stall
    await wait_pre_sample()
    assert dut.ar_ready.value == 0, "ar_ready not deasserted on stall"    
    # Assert r_ready, keep pipeline going
    dut.r_ready.value = 1
    await wait_pre_sample()
    assert dut.r_data.value == 13, "Data not loaded despite handshake" #1101
    #############################
    await RisingEdge(dut.clk)
    # R Handshake
    await wait_pre_sample()
    assert dut.ar_ready.value == 1, "ar_ready not reasserted despite stall end"
    #############################################################################################################
        # TEST 2: TBD
        # Tests TBD
    #############################################################################################################    