import socket
import numpy as np
import matplotlib.pyplot as plt
from matplotlib.animation import FuncAnimation

# === Configuración del socket UDP ===
UDP_IP = "10.42.0.100"
UDP_PORT = 2000
BUFFER_SIZE = 2048  # bytes por paquete

sock = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
sock.bind((UDP_IP, UDP_PORT))

# === Configuración de la ventana de datos ===
SAMPLES = 512  # Número total de muestras a mostrar
data_buffer = np.zeros(SAMPLES, dtype=np.int16)

# === Inicializar la figura de matplotlib ===
fig, ax = plt.subplots()
line, = ax.plot(data_buffer)
ax.set_ylim(-32768, 32767)  # Rango típico de int16
ax.set_title("Stream UDP int16")
ax.set_xlabel("Muestra")
ax.set_ylabel("Valor")

# === Función de actualización ===
def update(frame):
    global data_buffer
    try:
        data, _ = sock.recvfrom(BUFFER_SIZE)
        new_data = np.frombuffer(data, dtype='>i2')  # int16 little-endian
        # Deslizar la ventana
        shift = len(new_data)
        if shift >= SAMPLES:
            data_buffer[:] = new_data[-SAMPLES:]
        else:
            data_buffer = np.roll(data_buffer, -shift)
            data_buffer[-shift:] = new_data
        line.set_ydata(data_buffer)
    except BlockingIOError:
        pass
    return line,

# Opcional: no bloquear el socket
sock.setblocking(False)

# === Animación ===
ani = FuncAnimation(fig, update, interval=200)
plt.show()
