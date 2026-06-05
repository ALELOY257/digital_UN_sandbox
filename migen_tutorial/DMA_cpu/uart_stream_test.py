#!/usr/bin/env python3

from migen import *
from uart import RS232PHYTX
from litex.build.generic_platform import *


baudrate = 115200
clk_freq = 50e6
tuning = int((baudrate/clk_freq)*2**32)
pads = Record([
         ("tx", 1),
         ("rx", 1)
       ])
        
dut = RS232PHYTX(pads, tuning)

def write(value: int):
    yield dut.sink.payload.data.eq(value)
    yield dut.sink.valid.eq(1)
    yield
    yield dut.sink.payload.data.eq(0)
    yield
    yield dut.sink.valid.eq(0)
    while (yield dut.sink.ready != 1):    
        yield

def testbench():
    yield from write(0)
    yield from write(0xaa)
    yield from write(0x55)
    yield from write(0xff)

run_simulation(dut, testbench(), vcd_name="rs232-tx.vcd")