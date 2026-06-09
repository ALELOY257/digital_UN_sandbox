from migen import *
from migen.genlib.cdc import MultiReg
from litex.soc.interconnect.csr import *
from litex.soc.interconnect.csr_eventmanager import *


import os
src_dir = os.path.dirname(os.path.abspath(__file__))

class WS2812(Module, AutoCSR):
    def __init__(self, platform, data):

        self.init      = CSRStorage(1)
        self.rst_cmd   = CSRStorage(1)
        self.w_data    = CSRStorage(24)
        self.w_address = CSRStorage(8)        
        self.done      = CSRStatus(1)
        self.dout      = data.dout

        self.specials += Instance("ws2812_periph",
            i_clk       = ClockSignal("sys"),
            i_reset     = ResetSignal("sys"),
            i_init_m    = self.init.storage,
            i_rst_cmd   = self.rst_cmd.storage,
            i_w_data    = self.w_data.storage,
            i_w_address = self.w_address.storage,
            o_done      = self.done.status,
            o_dout      = self.dout,
        )

        for src in ["ctrl_wsled.v", "ws2812.v", "comp_ws_arr.v", "count_wsled.v",
                    "ws2812_led_array.v", "ctrl_ws.v", "comp_ws.v", "count_ws.v", "lsr_wsled.v", 
                    "ws2812_led.v", "ws2812_periph.v", "count_addr.v", "ctrl_ws_arr.v",
                    "led_mem_dual.v", "mux_ws.v"]:
            platform.add_source(os.path.join(src_dir, src))

'''

mem_write 0xf0000808 0x00FF00
mem_write 0xf000080C 0
mem_write 0xf000080C 1
mem_write 0xf000080C 2
mem_write 0xf000080C 3
mem_write 0xf000080C 4

mem_write 0xf0000800 1
mem_write 0xf0000800 0



'''