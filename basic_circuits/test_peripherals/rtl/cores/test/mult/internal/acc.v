module acc #(parameter WIDTH = 8) (
    input clk,
    input [WIDTH-1:0] A,
    input add,
    input rst,
    output reg [WIDTH-1:0] pp
);

initial pp = 0;

always @(posedge clk) begin
    if (rst)
        pp <= {WIDTH{1'b0}}; 
    else if (add)
        pp <= pp + A;
end
endmodule



