#!/usr/bin/env python3
import socket
import matplotlib.pyplot as plt
import matplotlib.animation as animation
from collections import deque
import struct
import numpy as np


# UDP configuration (must match DMAUpload settings)
UDP_IP = "10.42.0.100"    # Destination IP in your DMAUpload
UDP_PORT = 2000            # Destination port in your DMAUpload

def main():
    # Create UDP socket
    sock = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
    sock.bind((UDP_IP, UDP_PORT))
    print(f"Listening for UDP packets on {UDP_IP}:{UDP_PORT}...")


    while True:
        data, addr = sock.recvfrom(1024)
        arr = np.frombuffer(data, dtype='>i2')  # int16 little-endian
        hex_representation = [hex(x) for x in arr]
        print(hex_representation)
        print('BEGIN\n')
        print(arr)
        print('END\n')

    try:
        while True:
            # Receive data (buffer size = 1500 typical for Ethernet)
            data, addr = sock.recvfrom(1500)  
            print(f"Received {len(data)} bytes from {addr}:")
            
            # Imprimir como datos de 16 bits
            if len(data) % 2 == 0:
                # Si la longitud es par, procesar todos los bytes
                for i in range(0, len(data), 2):
                    value_16bit = int.from_bytes(data[i:i+2], byteorder='little')  # o 'big'
                    print(f"0x{value_16bit:04x} \n", end=" ")
                print()  # Nueva línea al final
            else:
                # Si la longitud es impar, procesar los pares y el último byte solo
                for i in range(0, len(data)-1, 2):
                    value_16bit = int.from_bytes(data[i:i+2], byteorder='little')
                    print(f"0x{value_16bit:04x}", end=" ")
                # Imprimir el último byte
                print(f"0x{data[-1]:02x}" )
                print('\n')
    except KeyboardInterrupt:
        print("\nStopped by user.")
    finally:
        sock.close()

if __name__ == "__main__":
    main()
