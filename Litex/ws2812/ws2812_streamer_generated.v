/* Machine-generated using Migen */
module ws2812_streamer_top(
	output dout,
	input storage,
	input storage_1,
	output status,
	input sink_valid,
	output sink_ready,
	input [31:0] sink_payload_data,
	input storage_2,
	input re,
	output status_1,
	output status_2,
	input sys_clk,
	input sys_rst
);

reg [23:0] loader_w_data = 24'd0;
reg [7:0] loader_w_address = 8'd0;
reg loader_we = 1'd0;
reg [7:0] loader_addr = 8'd0;
reg loader_busy = 1'd0;
reg loader_done = 1'd0;

// synthesis translate_off
reg dummy_s;
initial dummy_s <= 1'd0;
// synthesis translate_on

assign status_2 = loader_busy;
assign status_1 = loader_done;
assign sink_ready = loader_busy;

always @(posedge sys_clk) begin
	loader_we <= 1'd0;
	if (re) begin
		loader_addr <= 1'd0;
		loader_busy <= 1'd1;
		loader_done <= 1'd0;
		loader_w_address <= 1'd0;
		loader_w_data <= 1'd0;
	end else begin
		if (loader_busy) begin
			if ((sink_valid & sink_ready)) begin
				loader_w_data <= sink_payload_data[23:0];
				loader_w_address <= loader_addr;
				loader_we <= 1'd1;
				if ((loader_addr == 8'd255)) begin
					loader_addr <= 1'd0;
					loader_busy <= 1'd0;
					loader_done <= 1'd1;
				end else begin
					loader_addr <= (loader_addr + 1'd1);
				end
			end
		end
	end
	if (sys_rst) begin
		loader_w_data <= 24'd0;
		loader_w_address <= 8'd0;
		loader_we <= 1'd0;
		loader_addr <= 8'd0;
		loader_busy <= 1'd0;
		loader_done <= 1'd0;
	end
end

ws2812_periph ws2812_periph(
	.clk(sys_clk),
	.init_m(storage),
	.reset(sys_rst),
	.rst_cmd(storage_1),
	.w_address(loader_w_address),
	.w_data(loader_w_data),
	.we_a(loader_we),
	.done(status),
	.dout(dout)
);

endmodule

