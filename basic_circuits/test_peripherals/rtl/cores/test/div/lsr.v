module lsr #(parameter WIDTH=8)(
    input clk,
    input load,
    input shift,
    input [WIDTH-1:0] dividend,
    output reg [WIDTH-1:0] dividend_out
);
    always @(posedge clk) begin
        if (load)
            dividend_out <= dividend;
        else if (shift)
            dividend_out <= {dividend_out[WIDTH-2:0], 1'b0};
    end
endmodule