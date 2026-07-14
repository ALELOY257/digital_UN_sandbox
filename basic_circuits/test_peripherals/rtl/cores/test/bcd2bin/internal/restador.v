module restador #(parameter WIDTH=4)(
    input [WIDTH-1:0] slice,
    output [WIDTH-1:0] added_slice
);
    assign added_slice = slice - 3'd3;
endmodule