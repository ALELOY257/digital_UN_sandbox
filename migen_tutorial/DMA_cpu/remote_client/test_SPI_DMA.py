#!/usr/bin/env python3
from litex import RemoteClient

class SoCTester:
    def __init__(self, host="10.42.0.220", csr_json="../build/csr.json"):
        self.bus = RemoteClient(host=host)
        self.bus.open()
        
    def __enter__(self):
        return self
        
    def __exit__(self, exc_type, exc_val, exc_tb):
        self.bus.close()
        
    def reset(self):
        self.bus.regs.ctrl_reset.write(1)
        
def test_spi_dma(self, test_size=1024):
    print("=== SPI DMA Test ===")
    
    # Configure DMA
    self.bus.regs.spi_dma_control.write(0)  # Disable
    self.bus.regs.spi_dma_dma_writer_base.write(0x30000000)  # DMA buffer
    self.bus.regs.spi_dma_dma_length.write(test_size)
    
    # Generate test pattern in HyperRAM
    test_data = [i % 256 for i in range(test_size)]
    self.bus.write(0x30000000, test_data)
    
    # Start transfer
    self.bus.regs.spi_dma_control.write(1)  # Enable
    
    # Monitor status
    while (self.bus.regs.spi_dma_status.read() & 0x1):  # Wait while running
        pass
        
    # Verify received bytes
    received = self.bus.read(0x30000000, test_size)
    errors = sum(1 for a,b in zip(test_data, received) if a != b)
    print(f"SPI DMA Test: {errors} errors in {test_size} bytes")

def test_hyperram(self, base_addr=0x40000000, size=1024):
    print("=== HyperRAM Test ===")
    
    # Write pattern
    pattern = [0xAA55AA55, 0x55AA55AA, 0xDEADBEEF, 0xCAFEBABE]
    for i, val in enumerate(pattern):
        self.bus.write(base_addr + i*4, val)
    
    # Read back
    errors = 0
    for i, expected in enumerate(pattern):
        actual = self.bus.read(base_addr + i*4)
        if actual != expected:
            print(f"Error at 0x{(base_addr + i*4):08X}: {actual:08X} != {expected:08X}")
            errors += 1
            
    print(f"HyperRAM Test: {errors} errors in {len(pattern)} words")

def test_udp_stream(self, size=4096):
    print("=== UDP Streaming Test ===")
    
    # Configure DMA Upload
    self.bus.regs.dma_upload_control.write(0)  # Reset
    self.bus.regs.dma_upload_dma_reader_base.write(0x30000000)
    self.bus.regs.dma_upload_dma_reader_length.write(size)
    
    # Generate test data
    test_data = bytes([i % 256 for i in range(size)])
    self.bus.write(0x30000000, test_data)
    
    # Start transfer
    self.bus.regs.dma_upload_control.write(1)
    
    # Monitor status
    while not (self.bus.regs.dma_upload_done.read()):
        status = self.bus.regs.dma_upload_status.read()
        print(f"Sent: {self.bus.regs.dma_upload_bytes_sent.read()} bytes", end='\r')
    
    print(f"\nUDP Streaming Complete. {size} bytes sent")



if __name__ == "__main__":
    with SoCTester() as tester:
        print("Starting SoC Validation...")
        
        # Basic tests
        tester.test_hyperram()
        
        # SPI DMA test (requires SPI loopback)
        tester.test_spi_dma(1024)
        
        # Network test (requires UDP listener)
        print("Start UDP listener on 10.42.0.220:2000 before continuing")
        input("Press Enter to start UDP test...")
        tester.test_udp_stream(2048)
        
        print("All tests completed")


# Run this on your PC to verify UDP streaming
import socket

def udp_listener(port=2000):
    sock = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
    sock.bind(("0.0.0.0", port))
    print(f"Listening on UDP port {port}...")
    
    while True:
        data, addr = sock.recvfrom(4096)
        print(f"Received {len(data)} bytes from {addr}")
        # Verify first/last bytes
        print(f"First: {data[0]:02X}, Last: {data[-1]:02X}")

if __name__ == "__main__":
    udp_listener()
