TARGET=adc_reader
OBJ  = ${TARGET}.v
OBJS = ${OBJ} dpram.v memory_writer.v register_bank.v spi_driver.v  
SIM_OBJS =  ../../verilog_model/sky130_fd_sc_hd.v
SIM_OBJS += ../../verilog_model/primitives.v
SKY_LIB_TECH=/home/carlos/.volare/sky130A/libs.tech/openlane/
EFINITY_HOME  = /Work/CAD/efinity/2025.1/
EFXPT_HOME    = $(EFINITY_HOME)/pt
EFINIX_SIM_CELLS   = sim_models_efx/efx_ff.v  sim_models_efx/efx_dpram_5k.v sim_models_efx/efx_ram_5k.v sim_models_efx/efx_lut4.v sim_models_efx/efx_add.v sim_models_efx/efx_gbufce.v 
TOP           = adc_reader

BUILD_DIR = build

all: sim


sim:
	rm -f a.out *.vcd
	iverilog   $(TARGET)_TB.v $(OBJS)
	vvp a.out
	gtkwave $(TARGET)_TB.vcd

sim_post_syn_efinix:
	yosys -v3 -l synth.log -p ' synth_efinix -top adc_reader -json $(TOP).json; write_verilog -attr2comment $(TOP)_synth.v' ${OBJS}
	iverilog -DSYNTH -o $@_PS.vpp -s $(TARGET)_tb $(TARGET)_TB.v $(TOP)_synth.v $(EFINIX_SIM_CELLS) 
	vvp $@_PS.vpp
	gtkwave $(TOP)_TB.vcd &

svg: $(OBJ)
	yosys -p "prep -top ${TARGET}; write_json ${TARGET}.json" ${OBJ}
	netlistsvg ${TARGET}.json -o ${TARGET}.svg  #--skin default.svg
	yosys -p "prep -top ${TARGET} -flatten; write_json ${TARGET}_flat.json" ${OBJ}
	netlistsvg ${TARGET}_flat.json -o ${TARGET}_flat.svg  #--skin default.svg

svg_all: $(OBJS)
	yosys -p "prep -top ${TARGET}; write_json ${TARGET}.json" ${OBJS}
	netlistsvg ${TARGET}.json -o ${TARGET}.svg  #--skin default.svg
	yosys -p "prep -top ${TARGET} -flatten; write_json ${TARGET}_flat.json" ${OBJS}
	netlistsvg ${TARGET}_flat.json -o ${TARGET}_flat.svg  #--skin default.svg

clean:
	rm -rf *.out *.vcd *.svg *.json
