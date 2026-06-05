#!/usr/bin/env python3
#litex_server --udp --udp-ip=10.42.0.220
import time
import random

from litex import RemoteClient

wb = RemoteClient()
wb.open()

# # #

# test buttons
print("Testing PWM LED ...")
while True:
    prng = random.Random(42)
    brightness = 10
    print(".")
    wb.regs.pwm_enable.write(1)
    wb.regs.pwm_period.write(1024*40)
    for i in range(40):
        wb.regs.pwm_width.write(int(1024*i))
        time.sleep(0.01)
    for i in range(40):
        wb.regs.pwm_width.write(int(1024*(40-i)))
        time.sleep(0.01)
    wb.regs.pwm_enable.write(0)
    print(".")
    time.sleep(.1)
    

# # #

wb.close()
