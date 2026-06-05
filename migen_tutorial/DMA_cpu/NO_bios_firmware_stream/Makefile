BUILD_DIR=../build/
SERIAL?=/dev/ttyUSB1
include $(BUILD_DIR)/software/include/generated/variables.mak
include $(SOC_DIRECTORY)/software/common.mak
OBJECTS=  helpers.o main.o crt0.o
all: firmware.bin
# pull in dependency info for *existing* .o files
-include $(OBJECTS:.o=.d)
firmware.bin: firmware.elf
	$(PYTHON) -m litex.soc.software.memusage firmware.elf $(BUILD_DIR)/software/include/generated/regions.ld $(TRIPLE)
	$(OBJCOPY) -O binary $< $@
	chmod -x $@
firmware.elf: $(OBJECTS)
	$(CC) $(LDFLAGS) \
		-T linker.ld \
		-N -o $@ \
		-Wl,--whole-archive \
		-Wl,--gc-sections \
		-Wl,-Map,$@.map \
		$(OBJECTS) \
		$(PACKAGES:%=-L$(BUILD_DIR)/software/%) \
		$(LIBS:lib%=-l%)
	chmod -x $@
	@riscv64-unknown-elf-objdump  -h -S firmware.elf > firmware.lst
main.o: main.c
	$(compile)
crt0.o: $(CPU_DIRECTORY)/crt0.S
	$(assemble)	
%.o: %.c
	$(compile)
%.o: %.S
	$(assemble)
litex_term: firmware.bin
	@ls ${SERIAL} || (echo "\n\nNo se encuentra ${SERIAL} conectado, verifique conexión o cambie el valor de SERIAL=${SERIAL} por un puerto serial existente\n\n"; exit 123;)
	litex_term ${SERIAL} --kernel firmware.bin
clean:
	$(RM) $(OBJECTS) $(OBJECTS:.o=.d) firmware.elf firmware.bin .*~ *~ *.bin
.PHONY: all main.o clean load
