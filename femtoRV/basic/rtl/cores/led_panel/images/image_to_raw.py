from PIL import Image
import numpy as np

im = Image.open("S.png")
# Convertir a RGB si está en modo paleta
if im.mode == 'P':
    im = im.convert('RGB')

img = np.array(im)

# Abrir archivo para escritura
with open("../image.hex", "w") as f:
    for y in range(32):  # Mitad superior (filas 0-31)
        for x in range(64):  # Todas las columnas
            # Pixel mitad superior (y)
            r1 = (img[y,x,0] >> 7)      
            g1 = (img[y,x,1] >> 7)      
            b1 = (img[y,x,2] >> 7)      
            
            # Pixel mitad inferior (y+32)
            r2 = (img[y+32,x,0] >> 7)   
            g2 = (img[y+32,x,1] >> 7)   
            b2 = (img[y+32,x,2] >> 7)   
            
            # Formato: R1G1B1R2G2B2
            # Si azul puro (0,0,255) debe dar 100100
            # Esto significa: B1=1, G1=0, R1=0 -> orden invertido
            pixel_data = (b1 << 5) | (g1 << 4) | (r1 << 3) | (b2 << 2) | (g2 << 1) | r2
            
            f.write("%02X\n" % pixel_data)

print("Archivo generado: ../image.hex")