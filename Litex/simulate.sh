#!/bin/bash
set -e

SOC_SCRIPT="colorlight_i5_no_bios.py"
FW_DIR="NO_bios_fw"
BUILD_DIR="build/colorlight_i5"
ROM_SIZE=$((0xC000))

echo "========================================================"
echo " BUILD Y SIMULACIÓN - Colorlight i5 NO-BIOS"
echo "========================================================"

# PASO 1: dummy firmware.bin para romper dependencia cíclica
echo ""
echo "[1/7] Creando firmware.bin dummy de ${ROM_SIZE} bytes..."
dd if=/dev/zero of=${FW_DIR}/firmware.bin bs=1 count=${ROM_SIZE} status=none
echo "      OK: $(ls -lah ${FW_DIR}/firmware.bin | awk '{print $5, $9}')"

# PASO 2: generar regions.ld y CSR headers con tamaño correcto
echo ""
echo "[2/7] Generando regions.ld y headers CSR..."
python3 ${SOC_SCRIPT} --build --no-compile-gateware --no-compile-software 2>&1 | grep -E "INFO|ERROR|WARNING|rom|sram" || true
ROM_LENGTH=$(grep "rom" ${BUILD_DIR}/software/include/generated/regions.ld | grep -o "LENGTH = 0x[0-9a-fA-F]*" )
echo "      OK: regions.ld → rom ${ROM_LENGTH}"

# PASO 3: compilar librerías software (genera picolibc.h)
echo ""
echo "[3/7] Compilando librerías software (picolibc, libbase...)..."
python3 ${SOC_SCRIPT} --build --no-compile-gateware 2>&1 | tail -5
if [ -f "${BUILD_DIR}/software/libc/picolibc.h" ]; then
    echo "      OK: picolibc.h generado"
else
    echo "      ERROR: picolibc.h no encontrado"
    exit 1
fi

# PASO 4: compilar firmware real
echo ""
echo "[4/7] Compilando firmware..."
make -C ${FW_DIR}/ 2>&1
FW_SIZE=$(ls -lah ${FW_DIR}/firmware.bin | awk '{print $5}')
echo "      OK: firmware.bin = ${FW_SIZE}"
echo "      Secciones:"
size ${FW_DIR}/firmware.elf | tail -1 | awk '{printf "      text=%s data=%s bss=%s total=%s\n", $1, $2, $3, $4}'

# PASO 5: verificar que cabe en la ROM
FW_BYTES=$(stat -c%s ${FW_DIR}/firmware.bin)
if [ ${FW_BYTES} -gt ${ROM_SIZE} ]; then
    echo "      ERROR: firmware (${FW_BYTES} bytes) no cabe en ROM (${ROM_SIZE} bytes)"
    exit 1
fi
echo "      OK: firmware cabe en ROM (${FW_BYTES}/${ROM_SIZE} bytes)"

# PASO 6: regenerar SoC con firmware real embebido
echo ""
echo "[6/7] Embebiendo firmware en ROM del SoC..."
python3 ${SOC_SCRIPT} --build --no-compile-gateware --no-compile-software 2>&1 | grep -E "INFO|ERROR|WARNING" || true
if [ -f "${BUILD_DIR}/gateware/colorlight_i5_rom.init" ]; then
    INIT_LINES=$(wc -l < ${BUILD_DIR}/gateware/colorlight_i5_rom.init)
    echo "      OK: colorlight_i5_rom.init (${INIT_LINES} líneas)"
    echo "      Primeras 3 líneas:"
    head -3 ${BUILD_DIR}/gateware/colorlight_i5_rom.init | sed 's/^/      /'
else
    echo "      ERROR: colorlight_i5_rom.init no generado"
    exit 1
fi

# PASO 7: copiar .init y sintetizar para simulación
echo ""
echo "[7/7] Copiando .init y sintetizando para simulación..."
cp ${BUILD_DIR}/gateware/colorlight_i5_rom.init .
cp ${BUILD_DIR}/gateware/colorlight_i5_sram.init .
echo "      OK: archivos .init copiados"
make sim_lattice

echo ""
echo "========================================================"
echo " SIMULACIÓN COMPLETADA"
echo "========================================================"