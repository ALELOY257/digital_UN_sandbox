module comp_ws_arr (
    input [5:0] in1,
    input [5:0] in2,
    output reg   z
);

always @(*) begin
    if(in1 == in2)
        z <= 1;
    else
        z <= 0;
end

endmodule
