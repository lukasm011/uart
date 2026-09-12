import cocotb
from cocotb.clock import Clock
from cocotb.triggers import Timer, ClockCycles, RisingEdge

async def wait_pre_sample():
    await Timer(1, unit = "ns")

@cocotb.test()
async def axi_write_test(dut):
    #############################################################################################################
        # TEST 1: Stalling LOAD
        # Tests whether LOAD can safely stall and prevent new address transactions from taking place alongside
        # disabling further stages.
    #############################################################################################################
    clk = Clock(dut.clk, 10, unit = "ns")
    cocotb.start_soon(clk.start())
    # Reset write slave
    dut.rst.value = 0
    await ClockCycles(dut.clk, 2)
    dut.rst.value = 1
    # Set up busses
    dut.aw_addr.value = 4
    dut.aw_valid.value = 0
    dut.w_data.value = 0x55
    dut.w_valid.value = 0
    dut.rw_ready.value = 1
    dut.uart_full_tx.value = 1
    await RisingEdge(dut.clk)
    # Start address transmission
    dut.aw_valid.value = 1
    await RisingEdge(dut.clk) # AW Bus handshake
    dut.aw_addr.value = 8
    # No assertion of w_valid
    await wait_pre_sample()
    assert dut.aw_ready.value == 0, "AW Transaction initiated despite stall!"
    await RisingEdge(dut.clk)
    await wait_pre_sample()
    assert dut.addr_load.value == 1, "Loaded new address to LOAD when disabled!"
    assert dut.addr_resp.value == 0, "Loaded new address to RESP when disabled!"
    # Assert write data valid
    dut.w_valid.value = 1
    #############################
    await RisingEdge(dut.clk)
    # Brings w_ready high
    await wait_pre_sample()
    assert dut.w_ready.value == 1, "Not ready for read despite valid data and wait period"
    #############################
    await RisingEdge(dut.clk)
    # Executes W Handshake
    await wait_pre_sample()
    assert dut.data_reg.value == 0x55, "Did not load data despite handshake"
    assert dut.aw_ready.value == 1, "AW_READY not raised despite enabled stage"
    assert dut.rw_valid.value == 1, "RW not raised despite previous handshake"
    #############################
    await RisingEdge(dut.clk)
    # Executes AW/RW Handshake
    await wait_pre_sample()
    assert dut.addr_load.value == 2, "Did not load new address to LOAD despite handshake"
    #############################
    await RisingEdge(dut.clk)
    # Raises w_ready
    await wait_pre_sample()
    assert dut.w_ready.value == 1, "Did not raise w_ready despite enabled stage"
    dut.w_data.value = 0x54
    #############################
    await RisingEdge(dut.clk)
    # Executes W Handshake
    await wait_pre_sample()
    assert dut.data_reg.value == 0x54, "Did not load data despite handshake"
    #############################################################################################################
        # TEST 2: Stalling RESP
        # Tests whether RESP can safely stall and prevent new address transactions from taking place alongside
        # disabling previous stages.
    #############################################################################################################
    dut.aw_addr.value = 4
    dut.w_data.value = 0x53
    dut.rw_ready.value = 0
    #############################
    await RisingEdge(dut.clk)
    # Prevents RW Handshake, stalls previous stages
    await wait_pre_sample()
    assert dut.data_reg.value == 0x54, "Address loaded despite RESP stall"
    dut.rw_ready.value = 1
    #############################
    await RisingEdge(dut.clk)
    # Reasserts rw_valid
    await wait_pre_sample()
    assert dut.rw_valid.value == 1, "Did not reassert rw_valid"
    #############################
    await RisingEdge(dut.clk)
    # Reasserts w_valid
    #######################################################################################
        # NOTE: In case all stages are blocked, they are restarted in reverse order.
        # i.e. upon the release of RESP, LOAD is reactivated first, followed by DECODE.  
    #######################################################################################
    await wait_pre_sample()
    assert dut.w_valid.value == 1, "W_VALID not reasserted despite enabled stage"
    #############################
    await RisingEdge(dut.clk)
    # Executes W Handshake
    await wait_pre_sample()
    assert dut.data_reg.value == 0x53, "Data not loaded despite handshake"
    assert dut.aw_ready.value == 1, "AW_READY not reasserted despite enabled stage"
    #############################
    await RisingEdge(dut.clk)
    # Reasserts aw_ready and rw_valid
    await wait_pre_sample()
    assert dut.rw_ready.value == 1, "RW_READY not reasserted despite enabled stage"
    #############################
    await RisingEdge(dut.clk)
    # AW/RW handshake
    await wait_pre_sample()
    assert dut.addr_load.value == 1, "New address not loaded despite handshake"