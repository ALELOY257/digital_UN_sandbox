
module adc_reader #(
	parameter adr_width = 14
)
(
    input  [7:0] data_in,
    input                   busy,
    input                   clk,
    input                   reset,
    input [15:0]            spi_tx_data,
    input                   rstrb,
    input                   st_capture, 
    output                  ncs,
    output                  sclk,
    output                  st_conv,
    output                  dout,
    output                  reset_ad,
	  input				            re_b,
	  input  [adr_width-1:0]  adr_b,
    input [15:0]            sample_counter,
	  output [15:0]           dat_b,
    output                  done_tx,
    output                  done_capture,
    output [15:0]           spi_rx_data   
);


wire mem_busy;
wire end_frame;
wire we_a;
wire rb_sel;
wire rb_en;

wire st_tick_sample;
wire tick_sample;

wire [15:0] data_out1;
wire [15:0] data_out2;
reg  [15:0] mem_d_in;
wire [adr_width-1:0]  address;

register_bank reg_bank0(
  .clk(clk),
  .data_in(data_in),
  .en(~rb_en),
  .addr(address[2:0]),
  .data_out(data_out1)
);

register_bank reg_bank1(
  .clk(clk),
  .data_in(data_in),
  .en(rb_en),
  .addr(address[2:0]),
  .data_out(data_out2)
);


always @*
begin
    if (rb_sel)
      mem_d_in = data_out2;
    else
      mem_d_in = data_out1;
end

spi_driver spi0(
  .clk(clk),
  .reset(reset),
  .busy(busy),
  .mem_busy(mem_busy),
  .spi_tx_data(spi_tx_data),
  .rstrb(rstrb),  
  .sdin(data_in),
  .st_capture(st_capture),
  .done_capture(done_capture),
  .tick_sample(tick_sample),
  .ncs(ncs),
  .sclk(sclk),
  .st_conv(st_conv),
  .dout(dout),
  .reset_ad(reset_ad),
  .rb_en(rb_en),
  .end_frame(end_frame),
  .done_tx(done_tx),
  .st_tick_sample(st_tick_sample),
  .spi_rx_data(spi_rx_data)
);


timmer_sample timmer0(
    .clk(clk),
    .reset(reset),
    .st_tick_sample(st_tick_sample),
    .sample_counter(sample_counter), 
    .tick_sample(tick_sample)
);

memory_writer #(
	   .adr_width(adr_width )
   ) mem_wr0(
  .clk(clk),
  .reset(reset),
  .end_frame(end_frame),
  .st_capture(st_capture),
  .mem_busy(mem_busy),
  .rb_sel(rb_sel),
  .address(address),
  .done_capture(done_capture),
  .we_a(we_a)
);


dpram #(
	   .adr_width(adr_width),
	   .dat_width(16)
   )
  dpram0 (
  .clk_a(clk),
  .en_a(1'b1),
  .adr_a(address),
  .dat_a(mem_d_in),
  .we_a(we_a),

  .clk_b(clk),
  .en_b(1'b1),
  .re_b(re_b),
  .adr_b(adr_b),
  .dat_b(dat_b)
);

endmodule

