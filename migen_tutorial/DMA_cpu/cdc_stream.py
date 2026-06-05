#!/usr/bin/env python3
from migen                         import *
from migen.fhdl.decorators         import ClockDomainsRenamer
from litex.soc.interconnect.stream import AsyncFIFO
from litex.build.generic_platform  import *

clk_freq = 50e6
dut = ClockDomainsRenamer({"write": "usb", "read": "sys"})(AsyncFIFO([("data", 8)]))
dut.clock_domains += ClockDomain("usb")

def write(value: int, first=False, last=False):
    if first:
        yield dut.sink.first.eq(1)
    if last:
        yield dut.sink.last.eq(1)
    yield dut.sink.payload.data.eq(value)
    yield dut.sink.valid.eq(1)
    yield
    if first:
        yield dut.sink.first.eq(0)
    if last:
        yield dut.sink.last.eq(0)
    yield dut.sink.payload.data.eq(0)
    yield dut.sink.valid.eq(0)
    #yield

def testbench_usb():
    yield from write(0xaa, first=True)
    yield from write(0xbb)
    yield from write(0xcc)
    yield from write(0xdd)
    yield
    yield
    yield
    yield
    yield from write(0x55)
    yield from write(0xff, last=True)
    for i in range(0, 4):
        yield

def testbench_sys():
    yield dut.source.ready.eq(0)
    for i in range(0, 10):
        yield
    yield dut.source.ready.eq(1)
    for i in range(0, 20):
        yield
run_simulation(dut, dict(usb = testbench_usb(), sys = testbench_sys()), vcd_name="cdc-slow-to-fast.vcd", clocks={"sys": 10, "usb": 16})