#!/usr/bin/env python3
import os
import sys
import env_efinity
from migen import *
from platforms import get_platform, load_bitstream, parse_args, BUILD_DIR

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

TopModule    = PWMFade  # <-- cambia aquí el módulo a sintetizar
top_args_hw  = (16, 9)
top_args_sim = (8,  5)

# Simulation
def _test(dut):
    for i in range(20000):
        yield

# Main
if __name__ == "__main__":
    if len(sys.argv) > 1 and sys.argv[1] == "sim":
        pwm_out = Signal()
        dut     = TopModule(pwm_out, *top_args_sim)
        dut.clock_domains.cd_sys = ClockDomain("sys")
        run_simulation(dut, _test(dut), vcd_name="top.vcd")
    else:
        args = parse_args()
        os.makedirs(BUILD_DIR, exist_ok=True)

        platform, sys_clk_freq, led_name, bitstream = get_platform(args.platform)
        led = platform.request(led_name)
        top = TopModule(led, *top_args_hw)

        platform.build(top, build_dir=BUILD_DIR)
        load_bitstream(platform, args.platform, BUILD_DIR, bitstream)