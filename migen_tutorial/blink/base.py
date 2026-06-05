#!/usr/bin/env python3
import argparse
import os
import env_efinity 
from migen import *


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

def get_platform(name):
    if name == "colorlight_i9":
        from litex_boards.platforms import colorlight_i5
        return colorlight_i5.Platform(board="i9", revision="7.2", toolchain="trellis"), 25e6, "user_led_n", "top.bit"
    elif name == "ecb_t8":
        from board import ecb_t8_t113
        return ecb_t8_t113.Platform(), 33.333e6, "user_led_n", "outflow/top.hex"
    else:
        raise ValueError(f"Plataforma desconocida: {name}")

def load_bitstream(platform_name, build_dir, bitstream):
    bitstream_file = f"{build_dir}/{bitstream}"
    if platform_name == "ecb_t8":
        efinity = "/Work/CAD/efinity/2024.2"
        os.system(
            f'{efinity}/bin/python3 {efinity}/pgm/bin/efx_pgm/ftdi_program.py '
            f'{bitstream_file} -m passive '
            f'-b "Generic Board Profile Using FT2232H" '
            f'--url ftdi://0x0403:0x6010/1'
        )
    else:
        prog = platform.create_programmer()
        prog.load_bitstream(bitstream_file)

parser = argparse.ArgumentParser()
parser.add_argument("--platform", default="colorlight_i9",
                    choices=["colorlight_i9", "ecb_t8"])
args = parser.parse_args()

build_dir = os.path.abspath("build/gateware")
os.makedirs(build_dir, exist_ok=True)

platform, sys_clk_freq, led_name, bitstream = get_platform(args.platform)
led = platform.request(led_name, 0)
my_blinker = Blink(1, sys_clk_freq, led)

platform.build(my_blinker, build_dir=build_dir)
load_bitstream(args.platform, build_dir, bitstream)