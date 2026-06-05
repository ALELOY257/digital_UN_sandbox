#!/usr/bin/env python3
# export LITEX_ENV_EFINITY=/home/carlos/Embedded/efinity/2023.2/
from migen import *
from board import ecb_t8_t113
from litex.build.generic_platform import *
from litex.build.efinix import EfinixPlatform
from litex.soc.integration.soc_core import *
from litex.soc.integration.builder import *
from litex.soc.cores import dna
from litex.soc.cores.hyperbus import HyperRAM
from liteeth.phy.rmii import LiteEthPHYRMII



from pwm import PWM 
platform = ecb_t8_t113.Platform()
class BaseSoC(SoCCore):
    def __init__(self, platform, **kwargs):
        sys_clk_freq = int(33.333e6)
        SoCCore.__init__(self, platform,
            cpu_type                 = "femtorv",
            cpu_variant              = "gracilis",  #RV32IMCzCSR
            clk_freq                 = 33.333e6,
            ident                    = "LiteX CPU Test SoC", ident_version=True,
            integrated_rom_size      = 0x8000
            #integrated_main_ram_size = 0x4000
        )



        self.submodules.crg = CRG(platform.request("clk33"), ~platform.request("user_btn_n")) 
        self.ethphy = LiteEthPHYRMII(
          clock_pads = self.platform.request("eth_clocks"),
          pads       = self.platform.request("eth"),
          refclk_cd  = None)
        self.add_ethernet(phy=self.ethphy, data_width=32)

        self.submodules.pwm = PWM(platform.request("user_led",  0))   # PWM
        self.add_csr("pwm")
soc = BaseSoC(platform)
# Build --------------------------------------------------------------------------------------------
builder = Builder(soc, output_dir="build/", csr_csv="csr.csv")
builder.build(build_name="top")

