#!/usr/bin/env python3
import os
import sys
import env_efinity
from migen import *
from litex.build.generic_platform import *
from litex.soc.integration.soc_core import *
from litex.soc.integration.builder import *
from litex.soc.cores import dna
from litex.soc.cores.hyperbus import HyperRAM
from liteeth.phy.rmii import LiteEthPHYRMII
from pwm import PWM
from platforms import get_platform, load_bitstream, parse_args, BUILD_DIR

# Design
class BaseSoC(SoCCore):
    def __init__(self, platform, sys_clk_freq, **kwargs):
        SoCCore.__init__(self, platform,
            cpu_type                 = "femtorv",
            cpu_variant              = "gracilis",
            clk_freq                 = sys_clk_freq,
            ident                    = "LiteX CPU Test SoC", ident_version=True,
            integrated_rom_size      = 0x8000,
        )
        self.submodules.crg = CRG(platform.request("clk33"), ~platform.request("user_btn_n"))
        self.ethphy = LiteEthPHYRMII(
            clock_pads = self.platform.request("eth_clocks"),
            pads       = self.platform.request("eth"),
            refclk_cd  = None)
        self.add_ethernet(phy=self.ethphy, data_width=32)
        self.submodules.pwm = PWM(platform.request("user_led_n", 0))
        self.add_csr("pwm")

TopModule    = BaseSoC  # <-- cambia aquí el módulo a sintetizar

# Main
if __name__ == "__main__":
    args = parse_args()
    os.makedirs(BUILD_DIR, exist_ok=True)

    platform, sys_clk_freq, led_name, bitstream = get_platform(args.platform)
    top = TopModule(platform, sys_clk_freq)

    builder = Builder(top, output_dir=BUILD_DIR, csr_csv="csr.csv")
    builder.build(build_name="top")

    load_bitstream(platform, args.platform, BUILD_DIR, bitstream)