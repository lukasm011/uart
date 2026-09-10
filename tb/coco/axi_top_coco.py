import cocotb
from cocotb.triggers import Timer, RisingEdge, ClockCycles, gather
from cocotb.clock import Clock
from cocotbext.axi import AxiLiteMaster, AxiLiteBus

bit_time_slow = (10**9)//9600
bit_time_fast = (10**9)//115200
handshake = 0x55
data = 0x00
clk_per = (10**9) // 27_000_000

@cocotb.test()
async def my_test(dut):
    c = Clock(dut.clk, clk_per, unit = "ns")
    cocotb.start_soon(c.start())
    dut.rst.value = 0
    await ClockCycles(dut.clk, 2)
    dut.rst.value = 1
    await RisingEdge(dut.clk)
    axi_master = AxiLiteMaster(AxiLiteBus.from_prefix(dut, "s_axi"), dut.clk, dut.rst, False)
    await axi_master.write(0x04, b'U')
    await Timer(10*bit_time_slow, unit="ns") #Transmission takes place during this time
    await axi_master.write(0x04, b'T')
    await gather(axi_master.write(0x04, b'S'), axi_master.read(0x0C, 1))
    await Timer(20*bit_time_slow, unit="ns")
    assert (await axi_master.read(0x00, 1)).data[0] == 0x55, "Error!, got {}".format(a.data[0])
    a = await axi_master.read(0x00, 1)
    assert a.data[0] == 0x54, "Error!, got {}".format(a.data[0])
    a = await axi_master.read(0x00, 1)
    assert a.data[0] == 0x53, "Error!, got {}".format(a.data[0])
