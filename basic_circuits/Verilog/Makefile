TARGET = comp
OBJS   = ${TARGET}.v
sim:
	rm -f a.out *.vcd
	iverilog  $(TARGET)_TB.v $(OBJS)
	vvp a.out
	gtkwave $(TARGET)_TB.vcd
svg: $(OBJS)
	rm -rf *svg *out *dot
	# Para netlistsvg — convierte ROM a lógica antes de techmap
	yosys -p "prep -top ${TARGET}; memory_map; opt; opt_expr; techmap; abc -g AND,OR,XOR; write_json ${TARGET}.json" ${OBJS}
	# Para graphviz dot
	yosys -p "read_verilog ${TARGET}.v; proc; memory_map; opt; opt_expr; techmap; abc -g AND,OR,XOR; show -format dot -prefix ${TARGET}_out"
	dot -Tsvg ${TARGET}_out.dot -o ${TARGET}_out.svg
	netlistsvg ${TARGET}.json -o ${TARGET}.svg
	# Flatten
	yosys -p "prep -top ${TARGET} -flatten; memory_map; write_json ${TARGET}_flat.json" ${OBJS}
	netlistsvg ${TARGET}_flat.json -o ${TARGET}_flat.svg



clean:
	rm -rf *svg *out *dot a.out *.vcd *json
