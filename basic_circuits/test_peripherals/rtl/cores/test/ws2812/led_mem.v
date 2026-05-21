module led_mem(
   input             clk,
   input      [5:0]  address,
   output reg [23:0] data_r
);
    reg [23:0] MEM [0:63];
    initial begin
        $readmemh("./display.hex",MEM);
    end

    always @(negedge clk) begin
        data_r <= MEM[address];
    end

endmodule
