TARGET = comp  
ICE40_SIM_CELLS=./lattice_sim/cells_sim_ecp5.v

ifeq ($(TARGET), ws2812)
    OBJS = comp_ws.v  count_ws.v  ctrl_ws.v  mux_ws.v  ws2812.v
else ifeq ($(TARGET), ws2812_led)
    OBJS = comp_ws.v  count_ws.v  ctrl_ws.v  mux_ws.v  ws2812.v lsr_wsled.v count_wsled.v ctrl_wsled.v ws2812_led.v
else ifeq ($(TARGET), ws2812_array)
    OBJS = comp_ws.v  count_ws.v  ctrl_ws.v  mux_ws.v  ws2812.v lsr_wsled.v count_wsled.v ctrl_wsled.v ws2812_led.v 
else
    OBJS = ${TARGET}.v
endif

sim:
	rm -f a.out *.vcd
	iverilog  -DBENCH $(TARGET)_TB.v $(OBJS)
	vvp a.out
	gtkwave $(TARGET)_TB.vcd
sim_post_syn:
	yosys -v3 -l synth.log -p 'synth_ecp5 -top $(TARGET) -json $(TARGET).json; write_verilog -attr2comment $(TARGET)_synth.v' $(OBJS)
	iverilog  -I ./lattice_sim  $(TARGET)_TB.v $(TARGET)_synth.v $(ICE40_SIM_CELLS) 
	vvp a.out
	gtkwave $(TARGET)_TB.vcd
svg: $(OBJS)
	rm -rf *svg *out *dot
	yosys -p "prep -top ${TARGET}; memory_map; opt; opt_expr; techmap; abc -g AND,OR,XOR; write_json ${TARGET}.json" ${OBJS}
	yosys -p "read_verilog ${TARGET}.v; proc; memory_map; opt; opt_expr; techmap; abc -g AND,OR,XOR; show -format dot -prefix ${TARGET}_out"
	netlistsvg ${TARGET}.json -o ${TARGET}.svg
	google-chrome ${TARGET}.svg
clean:
	rm -rf *svg *out *dot a.out *.vcd *json *_synth.v *log
