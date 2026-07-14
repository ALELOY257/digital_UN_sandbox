module comp #(parameter WIDTH =8)(
    input [WIDTH-1:0] a,
    input [WIDTH-1:0] b,
    output wire v
);
    assign v = (a >= b) ? 1'b1 : 1'b0;
endmodule