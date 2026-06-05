#!/usr/bin/env python3
# export LITEX_ENV_EFINITY=/home/carlos/Embedded/efinity/2023.2/
from migen import *
from board import ecb_t8_t113
from litex.build.generic_platform import *
from litex.build.efinix import EfinixPlatform
from litex.soc.integration.soc_core import *
from litex.soc.integration.builder import *
from liteeth.phy.rmii import LiteEthPHYRMII
from litex.soc.cores import dna
from pwm import PWM 
platform = ecb_t8_t113.Platform()
class BaseSoC(SoCMini):
    def __init__(self, platform, **kwargs):
        sys_clk_freq = int(33.333e6)
        # SoCMini (No CPU, we are controlling the SoC over UART)
        SoCMini.__init__(self, platform, sys_clk_freq, csr_data_width=32,
            ident="My first LiteX System On Chip", ident_version=True)
        # Clock Reset Generation
        self.submodules.crg = CRG(platform.request("clk33"), ~platform.request("user_btn_n"))
        # No CPU, use Ethernet to control Wishbone bus

        self.ethphy = LiteEthPHYRMII(
            clock_pads = self.platform.request("eth_clocks"),
            pads       = self.platform.request("eth"),
            refclk_cd  = None
        )
        self.add_csr("ethphy")
        self.add_etherbone(
            phy         = self.ethphy,
            ip_address  = "10.42.0.220"        
        )
        # PWM
        self.submodules.pwm = PWM(platform.request("user_led",  0))
        self.add_csr("pwm")
soc = BaseSoC(platform)
# Build --------------------------------------------------------------------------------------------
builder = Builder(soc, output_dir="build/", csr_csv="csr.csv")
builder.build(build_name="top")