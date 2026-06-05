#!/usr/bin/env python3
# export LITEX_ENV_EFINITY=/home/carlos/Embedded/efinity/2023.2/
from migen import *
from board import ecb_t8_t113
# Design
# Create our platform (fpga interface)
# Create our module (fpga description)
class Blink(Module):
    def __init__(self, blink_freq, sys_clk_freq, led):
        counter = Signal(32)
        # synchronous assignments
        self.sync += [
            counter.eq(counter + 1),
            If(counter == int((sys_clk_freq/blink_freq)/2 - 1),
                counter.eq(0),
                led.eq(~led)
            )
        ]
        # combinatorial assignements
        self.comb += []
platform = ecb_t8_t113.Platform()
#clk33 = platform.request("clk33",0)
led = platform.request("user_led",0)
my_blinker = Blink(1, 33.333e6, led)
# Build --------------------------------------------------------------------------------------------
platform.build(my_blinker, build_dir="build/gateware")