import cocotb
from cocotb.clock import Clock
from cocotb.triggers import RisingEdge, ClockCycles, Timer
from cocotbext.axi import AxiLiteMaster, AxiLiteBus

async def wait_pre_sample():
    await Timer(1, unit = "ns")

bit_time_slow_ns = (10**9)//9600
bit_time_fast_ns = (10**9)//115200
clock_per = (10**9)//27_000_000

@cocotb.test()
async def axi_top_tb(dut):
    #############################################################################################################
        # TEST 1: Happy path
        # Tests whether the AXILite wrapper is compliant in the most basic case.
    #############################################################################################################
    clk = Clock(dut.clk, clock_per, unit = "ns")
    cocotb.start_soon(clk.start())
    # Reset DUT
    dut.rst.value = 0
    await ClockCycles(dut.clk, 2)
    almaster = AxiLiteMaster(AxiLiteBus.from_prefix(dut, "s_axi"), dut.clk, dut.rst, reset_active_level = False)
    dut.rst.value = 1
    #############################
    # Write Handshake byte and check validity
    await almaster.write(0x04, b'U')
    await Timer(11*bit_time_slow_ns, unit = "ns")
    assert (await almaster.read(0x00, 1)).data[0] == 0x55, "Transmission not received"
    #############################
    # Trigger Reset and Resend Handshake Byte + 1 Data Byte with Fast Mode
    to_send = bytearray(1)
    to_send[0] = 0x09 #Reset and set sel = 4 (meaning 9600 baud)
    await almaster.write(0x08, to_send)
    await almaster.write(0x04, b'U')
    await almaster.write(0x04, b'T')
    #############################
    await Timer(20*bit_time_fast_ns, unit = "ns")
    await almaster.read(0x00, 1) #Reads Handshake byte
    read = await almaster.read(0x00, 1)
    assert read.data[0] == 0x54, "Transmission not received, have response {}.".format(read.resp)
    almaster.wait_write()
    #############################