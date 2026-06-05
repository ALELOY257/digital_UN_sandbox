#!/usr/bin/env python3
import time
import random
from litex import RemoteClient
wb = RemoteClient()
wb.open()
print("Testing PWM LED ...")
while True:
    print(".")
    wb.regs.pwm_enable.write(1)
    wb.regs.pwm_period.write(1024*40)
    for i in range(40):
        wb.regs.pwm_width.write(int(1024*i))
        time.sleep(0.01)
    for i in range(40):
        wb.regs.pwm_width.write(int(1024*(40-i)))
        time.sleep(0.1)
    wb.regs.pwm_enable.write(0)
    print(".")
    time.sleep(.1)
wb.close()
