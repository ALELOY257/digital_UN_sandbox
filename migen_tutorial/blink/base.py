#!/usr/bin/env python3
import argparse
import os
import sys
import env_efinity 
from migen import *

from platforms import get_platform, load_bitstream, parse_args, BUILD_DIR


class Blink(Module):
    def __init__(self, blink_freq, sys_clk_freq, led):
        counter = Signal(32)
        self.sync += [
            counter.eq(counter + 1),
            If(counter == int((sys_clk_freq/blink_freq)/2 - 1),
                counter.eq(0),
                led.eq(~led)
            )
        ]
        self.comb += []


##############################################################################
##############################################################################

# Top-level
TopModule = Blink  # <-- cambia aquí el módulo a sintetizar

def _test(dut):
    for i in range(20000):
        yield

if len(sys.argv) > 1 and sys.argv[1] == "sim":
    pwm_out = Signal()
    dut     = TopModule(pwm_out, 8, 5)
    dut.clock_domains.cd_sys = ClockDomain("sys")
    run_simulation(dut, _test(dut), vcd_name="pwm_fade.vcd")
else:
    args = parse_args()
    os.makedirs(BUILD_DIR, exist_ok=True)

    platform, sys_clk_freq, led_name, bitstream = get_platform(args.platform)
    led = platform.request(led_name)
    top = TopModule(1, sys_clk_freq, led)

    platform.build(top, build_dir=BUILD_DIR)
    load_bitstream(platform, args.platform, BUILD_DIR, bitstream)