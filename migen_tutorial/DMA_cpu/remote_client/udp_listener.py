#!/usr/bin/env python3
import socket

# UDP configuration (must match DMAUpload settings)
UDP_IP = "10.42.0.100"    # Destination IP in your DMAUpload
UDP_PORT = 2000            # Destination port in your DMAUpload

def main():
    # Create UDP socket
    sock = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
    sock.bind((UDP_IP, UDP_PORT))
    print(f"Listening for UDP packets on {UDP_IP}:{UDP_PORT}...")

    try:
        while True:
            # Receive data (buffer size = 1500 typical for Ethernet)
            data, addr = sock.recvfrom(150)  
            print(f"Received {len(data)} bytes from {addr}:")
            print(" ".join(f"{b:02x}" for b in data))  # Hex dump
    except KeyboardInterrupt:
        print("\nStopped by user.")
    finally:
        sock.close()

if __name__ == "__main__":
    main()
