#!/usr/bin/env python3
# export LITEX_ENV_EFINITY=/home/carlos/Embedded/efinity/2023.2/
from migen import *
from board import ecb_t8_t113
from litex.build.generic_platform import *
from litex.build.efinix import EfinixPlatform
from litex.soc.integration.soc_core import *
from litex.soc.integration.builder import *
from litex.soc.cores import dna
from pwm import PWM
from module import my_uart
_custom_serial = [
    ("custom_serial", 1,
        Subsignal("uart_txd", Pins("141")),  # J1.3
        Subsignal("uart_rxd", Pins("139")),  # J1.5
        IOStandard("LVCMOS33")
    ),
]
platform = ecb_t8_t113.Platform()
class BaseSoC(SoCCore):
    def __init__(self, platform, **kwargs):
        sys_clk_freq = int(33.333e6)
        platform.add_extension(_custom_serial)
        platform.add_source("module/my_uart.v")
        SoCCore.__init__(self, platform,
            cpu_type                 = "vexriscv",
            clk_freq                 = 33.333e6,
            ident                    = "LiteX CPU Test SoC", ident_version=True,
            integrated_rom_size      = 0x8000,
            integrated_main_ram_size = 0x4000)
        self.submodules.crg = CRG(platform.request("clk33"), ~platform.request("user_btn_n")) 
        self.submodules.pwm = PWM(platform.request("user_led",  0))   # PWM
        SoCCore.add_csr(self,"uart_ver")
        self.submodules.uart_ver = my_uart.Verilog_UART(platform.request("custom_serial",1))
        self.add_csr("pwm")
soc = BaseSoC(platform)
# Build --------------------------------------------------------------------------------------------
builder = Builder(soc, output_dir="build/", csr_csv="csr.csv")
builder.build(build_name="top")

