#!/usr/bin/env python3
import os
#os.system("openFPGALoader -b trion_t120_bga576  build/gateware/top.bit")

os.system("python3  /Work/CAD/efinity/2024.2/pgm/bin/efx_pgm/ftdi_program.py build/gateware/outflow/top.hex  -m passive -b \"Generic Board Profile Using FT2232H\" --url ftdi://0x0403:0x6010/1" )
