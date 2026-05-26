module comparator #(
    parameter WIDTH = 8
)(
    input  wire [WIDTH-1:0] a, 
    input  wire [WIDTH-1:0] b, 
    output wire             v  
);
    assign v = (a >= b) ? 1'b1 : 1'b0;

endmodule