#!/usr/bin/env python3
# export LITEX_ENV_EFINITY=/home/carlos/Embedded/efinity/2023.2/
from migen import *
from litex.gen import *
from migen.genlib.io import CRG
from litex.soc.cores.clock import *
from litex.build.generic_platform import IOStandard, Subsignal, Pins
from litex_boards.platforms import cain_test
from litex.soc.integration.soc_core import *
from litex.soc.integration.builder import *
from litex.soc.cores.led import LedChaser
from board import ecb_t8_t113

# IOs ------------------------------------------------------------------------
# Clocl Reset PLL ------------------------------------------------------------
class _CRG(LiteXModule):
    def __init__(self, platform, sys_clk_freq):
        self.rst    = Signal()
        self.cd_sys = ClockDomain()
        # # #
        clk33 = platform.request("clk33")
        rst_n = platform.request("user_btn_n", 0)
        # PLL
        self.pll = pll = TRIONPLL(platform)
        self.comb += pll.reset.eq(~rst_n | self.rst)
        pll.register_clkin(clk33, 33.333e6)
        pll.create_clkout(self.cd_sys, sys_clk_freq, with_reset=True)

# BaseSoC --------------------------------------------------------------------
class BaseSoC(SoCCore):
    def __init__(self):
        platform = ecb_t8_t113.Platform()
        sys_clk_freq = int(99.999e6)
        # SoC with CPU
        SoCCore.__init__(
            self, platform,
            cpu_type                 = "femtorv",
            clk_freq                 = sys_clk_freq, 
            ident                    = "LiteX SoC on Efinix Trion T20ECB_T8_T113 Board", ident_version=True,
            integrated_rom_size      = 0x8000,
            integrated_main_ram_size = 0x4000)
        # Clock Reset Generation
        self.crg = _CRG(platform, sys_clk_freq)
        # Leds -------------------------------------------------------------------------------------
        self.leds = LedChaser(
            pads         = platform.request_all("user_led"),
            sys_clk_freq = sys_clk_freq)
def main():
   soc = BaseSoC()
   builder = Builder(soc, output_dir="build", csr_csv="csr.csv", csr_svd="csr.svd")
   builder.build()

if __name__ == "__main__":
    main()


















