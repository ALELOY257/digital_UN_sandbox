#!/usr/bin/env python3
# export LITEX_ENV_EFINITY=/home/carlos/Embedded/efinity/2023.2/
from migen import *
from migen.genlib.io import CRG
from litex.build.generic_platform import IOStandard, Subsignal, Pins
from litex_boards.platforms import cain_test
from litex.soc.integration.soc_core import *
from litex.soc.integration.builder import *
from litex.soc.cores.led import LedChaser
from board import ecb_t8_t113

# IOs ------------------------------------------------------------------------
2
# BaseSoC --------------------------------------------------------------------
class BaseSoC(SoCCore):
    def __init__(self):
        platform = ecb_t8_t113.Platform()
        sys_clk_freq = int(33.333e6)
        # SoC with CPU
        SoCCore.__init__(
            self, platform,
            cpu_type                 = "vexriscv",
            clk_freq                 = sys_clk_freq, 
            ident                    = "LiteX SoC on Efinix Trion T20ECB_T8_T113 Board", ident_version=True,
            integrated_rom_size      = 0x8000,
            integrated_main_ram_size = 0x4000)
        # Clock Reset Generation
        self.submodules.crg = CRG( platform.request("clk33"),
            ~platform.request("user_btn_n")
        )
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


















