module restador #(
    parameter WIDTH = 8
)(
    input  wire [WIDTH-1:0] a, 
    input  wire [WIDTH-1:0] b, 
    output wire [WIDTH-1:0] sub_out
);
    assign sub_out = a - b;

endmodule