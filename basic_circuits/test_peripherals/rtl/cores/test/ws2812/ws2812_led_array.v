module ws2812_led_array (
    input    reset,
    input    clk,
    input    init_m,
    input    rst_cmd,
    output   dout,
    output   done
);

parameter N_LEDS = 6'd64;

wire init_led;
wire rst_addr;
wire inc_addr;
wire done_led;
wire z;
wire [5:0] address;
wire [23:0] rgb;

led_mem     mem0    ( .clk(clk), .address(address), .data_r(rgb) );
ws2812_led  ws2812_0( .clk(clk), .reset(reset), .rgb(rgb), .init(init_led), .rst_cmd(rst_cmd), .dout(dout), .done(done_led) );
count_addr  count0  ( .clk(clk), .rst(reset), .inc(inc), .address(address) );
ctrl_ws_arr ctrl0   ( .clk(clk), .reset(reset), .init_m(init_m), .done_led(done_led), .z(z), .done(done), .init_led(init_led), .rst(rst), .inc(inc) );
comp_ws_arr comp0   ( .in1(address), .in2(N_LEDS), .z(z) );


endmodule
