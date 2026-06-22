#!/usr/bin/env python3
from migen import *
from migen.fhdl import verilog
from ws2812_streamer import WS2812


class DummyPlatform:
    def __init__(self):
        self.sources = []
    def add_source(self, path):
        self.sources.append(path)

class DataPads:
    def __init__(self):
        self.dout = Signal(name="dout")


if __name__ == "__main__":
    platform = DummyPlatform()
    data = DataPads()
    dut = WS2812(platform, data, n_leds=256)
    dut.clock_domains.cd_sys = ClockDomain("sys")

    ios = {
        # Clock/reset.
        dut.cd_sys.clk,
        dut.cd_sys.rst,

        # LiteX stream endpoint toward DMA reader.
        dut.sink.valid,
        dut.sink.ready,
        dut.sink.data,

        # CSRs used by software/testbench.
        dut.init.storage,
        dut.rst_cmd.storage,
        dut.loader.start.storage,
        dut.loader.start.re,
        dut.loader.done.status,
        dut.loader.busy.status,
        dut.done.status,

        # External WS2812 output.
        dut.dout,
    }

    converted = verilog.convert(
        dut,
        ios=ios,
        name="ws2812_streamer_top",
        create_clock_domains=False,
    )

    with open("ws2812_streamer_generated.v", "w") as f:
        f.write(str(converted))

    print("Generated ws2812_streamer_generated.v")
    print("Verilog sources used by blackbox ws2812_periph:")
    for source in platform.sources:
        print("  " + source)
