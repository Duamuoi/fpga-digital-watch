import cocotb
from cocotb.clock import Clock
from cocotb.triggers import RisingEdge, Timer


@cocotb.test()
async def test_cycle_count_1(dut):
    cocotb.start_soon(Clock(dut.clk, 10, units="ns").start())

    dut.run.value = 0
    await RisingEdge(dut.clk)
    await Timer(1, units="ns")
    assert dut.tick.value == 0

    dut.run.value = 1
    await RisingEdge(dut.clk)
    await Timer(1, units="ns")
    assert dut.tick.value == 1

    dut.run.value = 0
    await RisingEdge(dut.clk)
    await Timer(1, units="ns")
    assert dut.tick.value == 0

    dut.run.value = 1
    await RisingEdge(dut.clk)
    await Timer(1, units="ns")
    assert dut.tick.value == 1
