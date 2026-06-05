#!/usr/bin/env python3
# export LITEX_ENV_EFINITY=/home/carlos/Embedded/efinity/2023.2/
from migen import *
from migen.genlib.resetsync import AsyncResetSynchronizer
from litex.gen import *
from litex.build.generic_platform import *
from litex.soc.cores.clock import *
from litex.soc.integration.soc_core import *
from litex.soc.integration.soc import SoCRegion
from litex.soc.integration.builder import *
from litex.soc.interconnect import wishbone
from litex.soc.cores.led import LedChaser
from liteeth.phy.rmii import LiteEthPHYRMII
from board import ecb_t8_t113

# IOs ------------------------------------------------------------------------
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
    def __init__(self, sys_clk_freq = 99.999e6,
        with_spi_flash      = False,
        with_led_chaser     = True,
        with_ethernet       = False,
        with_etherbone      = False,
        eth_ip              = "10.42.0.220",
        eth_dynamic_ip      = False, 
        **kwargs):
        platform = ecb_t8_t113.Platform()
        # CRG --------------------------------------------------------------------------------------
        self.crg = _CRG(platform, sys_clk_freq)
        
        # SoC with CPU
        SoCCore.__init__(
            self, platform,
#            cpu_type                 = "lm32",
            clk_freq                 = sys_clk_freq, 
#            ident                    = "LiteX SoC on Efinix Trion T20ECB_T8_T113 Board", ident_version=True,
#            integrated_rom_size      = 0x8000,
            integrated_main_ram_size = 0x4000,
            **kwargs)
        # Leds -------------------------------------------------------------------------------------
        if with_led_chaser:
            self.leds = LedChaser(
                pads         = platform.request_all("user_led"),
                sys_clk_freq = sys_clk_freq)
def main():
    from litex.build.parser import LiteXArgumentParser
    parser = LiteXArgumentParser(platform=ecb_t8_t113.Platform, description="LiteX SoC on Efinix Trion T20 BGA256 Dev Kit.")
    parser.add_target_argument("--flash",          action="store_true",   help="Flash bitstream.")
    parser.add_target_argument("--sys-clk-freq",   default=99.999e6,       type=float, help="System clock frequency.")
    args = parser.parse_args()
    soc = BaseSoC(
        sys_clk_freq   = args.sys_clk_freq,
         **parser.soc_argdict)
    builder = Builder(soc, **parser.builder_argdict)
    if args.build:
        builder.build(**parser.toolchain_argdict)

    if args.load:
        from litex.build.openfpgaloader import OpenFPGALoader
        prog = OpenFPGALoader("trion_t120_bga576")
        prog.load_bitstream(builder.get_bitstream_filename(mode="sram", ext=".bit"))

    if args.flash:
        from litex.build.openfpgaloader import OpenFPGALoader
        prog = OpenFPGALoader("trion_t120_bga576")
        prog.flash(0, builder.get_bitstream_filename(mode="flash", ext=".hex")) # FIXME

if __name__ == "__main__":
    main()


















