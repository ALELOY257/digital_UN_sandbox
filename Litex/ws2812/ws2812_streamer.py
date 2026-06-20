from migen import *
from litex.soc.interconnect.csr import *
from litex.soc.interconnect import stream

import os
src_dir = os.path.dirname(os.path.abspath(__file__))


class WS2812StreamLoader(Module, AutoCSR):
    def __init__(self, n_leds=256):
        self.sink = sink = stream.Endpoint([("data", 32)])
        self.start = CSRStorage(1)
        self.done  = CSRStatus(1)
        self.busy  = CSRStatus(1)

        self.w_data    = Signal(24)
        self.w_address = Signal(max=n_leds)
        self.we        = Signal()

        addr = Signal(max=n_leds)
        busy = Signal(reset=0)
        done = Signal(reset=0)

        self.comb += [
            self.busy.status.eq(busy),
            self.done.status.eq(done),

            # Backpressure toward DMA Reader.
            # DMA words are accepted only while the loader is active.
            sink.ready.eq(busy),

            # One 32-bit DMA word per LED: 0x00RRGGBB.
            self.w_data.eq(sink.data[0:24]),
            self.w_address.eq(addr),
            self.we.eq(sink.valid & sink.ready),
        ]

        self.sync += [
            If(self.start.re,
                addr.eq(0),
                busy.eq(1),
                done.eq(0)
            ).Elif(busy,
                If(sink.valid & sink.ready,
                    If(addr == (n_leds - 1),
                        addr.eq(0),
                        busy.eq(0),
                        done.eq(1)
                    ).Else(
                        addr.eq(addr + 1)
                    )
                )
            )
        ]



class WS2812(Module, AutoCSR):
    def __init__(self, platform, data, n_leds=256):
        # Existing WS2812 control/status CSR
        self.init    = CSRStorage(1)
        self.rst_cmd = CSRStorage(1)
        self.done    = CSRStatus(1)
        self.dout    = data.dout

        # DMA stream loader
        self.submodules.loader = WS2812StreamLoader(n_leds=n_leds)
        self.sink = self.loader.sink

        # Explicit connection:
        #   DMA stream -> WS2812StreamLoader -> ws2812_periph memory write port
        self.specials += Instance("ws2812_periph",
            i_clk       = ClockSignal("sys"),
            i_reset     = ResetSignal("sys"),
            i_init_m    = self.init.storage,
            i_rst_cmd   = self.rst_cmd.storage,

            # These three signals replace CSR w_data/w_address/we_a.
            i_we_a      = self.loader.we,
            i_w_data    = self.loader.w_data,
            i_w_address = self.loader.w_address,

            o_done      = self.done.status,
            o_dout      = self.dout,
        )

        for src in ["ctrl_wsled.v", "ws2812.v", "comp_ws_arr.v", "count_wsled.v",
                    "ws2812_led_array.v", "ctrl_ws.v", "comp_ws.v", "count_ws.v", "lsr_wsled.v",
                    "ws2812_led.v", "ws2812_periph.v", "count_addr.v", "ctrl_ws_arr.v",
                    "led_mem_dual.v", "mux_ws.v"]:
            platform.add_source(os.path.join(src_dir, src))


def ws2812_stream_loader_tb(dut):
    test_pixels = [
        0x00112233,
        0x00445566,
        0x00778899,
        0x00AABBCC,
        0x00010203,
        0x00040506,
        0x00070809,
        0x000A0B0C,
    ]

    # Initial state
    yield dut.start.storage.eq(0)
    yield dut.sink.valid.eq(0)
    yield dut.sink.data.eq(0)
    for _ in range(4):
        yield

    # Start loader
    yield dut.start.storage.eq(1)
    yield
    yield dut.start.storage.eq(0)
    yield

    # Send one 32-bit word per LED.
    for i, pixel in enumerate(test_pixels):
        yield dut.sink.data.eq(pixel)
        yield dut.sink.valid.eq(1)

        while (yield dut.sink.ready) == 0:
            yield

        yield

        we = (yield dut.we)
        w_address = (yield dut.w_address)
        w_data = (yield dut.w_data)

        assert we == 1, "loader did not generate we on accepted stream word"
        assert w_address == i, "wrong write address: got %d expected %d" % (w_address, i)
        assert w_data == (pixel & 0x00ffffff), "wrong write data: got 0x%06x expected 0x%06x" % (
            w_data, pixel & 0x00ffffff)

    yield dut.sink.valid.eq(0)
    yield dut.sink.data.eq(0)

    for _ in range(4):
        yield

    assert (yield dut.done.status) == 1, "loader did not assert done after N LEDs"
    assert (yield dut.busy.status) == 0, "loader busy still asserted after N LEDs"

    for _ in range(8):
        yield


if __name__ == "__main__":
    from migen.sim import run_simulation

    dut = WS2812StreamLoader(n_leds=8)
    run_simulation(
        dut,
        ws2812_stream_loader_tb(dut),
        vcd_name="ws2812_streamer_tb.vcd"
    )
