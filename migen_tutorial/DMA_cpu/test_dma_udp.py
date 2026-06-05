from litex import RemoteClient
import time

wb = RemoteClient()
wb.open()



for i in range(0, 1, 200):
    addr = 0x40000000
    value = 0x12345678 + (i // 4)
    wb.regs.dma_upload_dma_reader_base.write(0x40000000 + i) 
    wb.write(addr + i, value)
    time.sleep(0.05)

# Configure DMA
wb.regs.dma_upload_dma_reader_enable.write(0)
wb.regs.dma_upload_dma_reader_base.write(0x40000000)
wb.regs.dma_upload_dma_reader_length.write(2048)
wb.regs.dma_upload_dma_reader_enable.write(1)
wb.regs.dma_upload_dma_reader_enable.write(0)


# Configure UDP destination IP and port
wb.regs.dma_upload_udp_streamer_enable.write(0)

wb.regs.dma_upload_udp_streamer_ip_address.write(0x0A2A0064)  # 10.42.0.220 in hex
wb.regs.dma_upload_udp_streamer_udp_port.write(2000)
wb.regs.dma_upload_dma_reader_loop.write(0)
wb.regs.dma_upload_udp_streamer_enable.write(1)
time.sleep(0.5)
wb.regs.dma_upload_dma_reader_loop.write(0)

# Try reading from the memory range


#dma_upload_dma_reader_offset

time.sleep(0.5)

# Check all debug signals
print('DMA base:', hex(wb.regs.dma_upload_dma_reader_base.read()))
print('DMA length:', wb.regs.dma_upload_dma_reader_length.read())
print('DMA enable:', wb.regs.dma_upload_dma_reader_enable.read())
print('DMA done:', wb.regs.dma_upload_dma_reader_done.read())
print('UDP dest_ip:', hex(wb.regs.dma_upload_udp_streamer_ip_address.read()))
print('UDP dest_port:', wb.regs.dma_upload_udp_streamer_udp_port.read())
print('UDP enable:', wb.regs.dma_upload_udp_streamer_enable.read())


wb.close()