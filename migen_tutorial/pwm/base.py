#!/usr/bin/env python3
import os
import sys
import env_efinity
from migen import *

# Design
class PWM(Module):
    def __init__(self, pwm, bitwidth, value):
        pwm_counter = Signal(bitwidth)
        self.comb += pwm.eq(pwm_counter < value)
        self.sync += pwm_counter.eq(pwm_counter + 1)

class TickUpdownCounter(Module):
    def __init__(self, counter, tick, bitwidth):
        icounter     = Signal(bitwidth+1)
        direction    = Signal()
        icounter_inv = Signal(bitwidth)

        self.comb += direction.eq(icounter[bitwidth])
        self.comb += If(direction,
                        counter.eq(~icounter[0:bitwidth])
                     ).Else(
                        counter.eq( icounter[0:bitwidth]))
        self.comb += icounter_inv.eq(~icounter[0:bitwidth])
        self.sync += If(tick,
                        If(icounter_inv == 0,
                            icounter.eq(icounter + 2)
                        ).Else(
                            icounter.eq(icounter + 1)))

class ClockDiv(Module):
    def __init__(self, divbitwidth, divout, divtick):
        divcounter     = Signal(divbitwidth+1)
        divcounter_inv = Signal(divbitwidth)
        self.sync += divcounter.eq(divcounter + 1)
        self.comb += divout.eq(divcounter[divbitwidth])
        self.comb += divcounter_inv.eq(~divcounter[0:divbitwidth])
        self.comb += divtick.eq(divcounter_inv == 0)

class PWMFade(Module):
    def __init__(self, pwm_signal, width, div):
        pwm_value           = Signal(width)
        updown_clock        = Signal()
        updown_clock_strobe = Signal()

        self.submodules.pwm            = PWM(pwm_signal, width, pwm_value)
        self.submodules.updown_clk_div = ClockDiv(div, updown_clock, updown_clock_strobe)
        self.submodules.updown         = TickUpdownCounter(pwm_value, updown_clock_strobe, width)

TopModule = PWMFade  # <-- cambia aquí el módulo a sintetizar

# Simulation
def _test(dut):
    for i in range(20000):
        yield

# Platform
def get_platform(name):
    if name == "colorlight_i9":
        from litex_boards.platforms import colorlight_i5
        return colorlight_i5.Platform(board="i9", revision="7.2", toolchain="trellis"), 25e6, "user_led_n", "top.bit"
    elif name == "ecb_t8":
        from board import ecb_t8_t113
        return ecb_t8_t113.Platform(), 33.333e6, "user_led_n", "outflow/top.hex"
    else:
        raise ValueError(f"Plataforma desconocida: {name}")

def load_bitstream(platform, platform_name, build_dir, bitstream):
    bitstream_file = f"{build_dir}/{bitstream}"
    if platform_name == "ecb_t8":
        efinity = os.environ["EFINITY_HOME"]
        os.system(
            f'{efinity}/bin/python3 {efinity}/pgm/bin/efx_pgm/ftdi_program.py '
            f'{bitstream_file} -m passive '
            f'-b "Generic Board Profile Using FT2232H" '
            f'--url ftdi://0x0403:0x6010/1'
        )
    else:
        prog = platform.create_programmer()
        prog.load_bitstream(bitstream_file)

# Main
if __name__ == "__main__":
    if len(sys.argv) > 1 and sys.argv[1] == "sim":
        pwm_out = Signal()
        dut     = TopModule(pwm_out, 8, 5)
        dut.clock_domains.cd_sys = ClockDomain("sys")
        run_simulation(dut, _test(dut), vcd_name="pwm_fade.vcd")
    else:
        import argparse
        parser = argparse.ArgumentParser()
        parser.add_argument("--platform", default="colorlight_i9",
                            choices=["colorlight_i9", "ecb_t8"])
        args = parser.parse_args()

        build_dir = os.path.abspath("build/gateware")
        os.makedirs(build_dir, exist_ok=True)

        platform, sys_clk_freq, led_name, bitstream = get_platform(args.platform)
        led = platform.request(led_name)
        top = TopModule(led, 16, 9)

        platform.build(top, build_dir=build_dir)
        load_bitstream(platform, args.platform, build_dir, bitstream)