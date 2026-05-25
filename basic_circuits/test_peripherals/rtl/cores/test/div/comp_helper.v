module comp_helper #(parameter WIDTH=8)(
    input signed [WIDTH-1:0] reg_ca2,
    output reg v
);
    always @(*) begin
        if (reg_ca2 < 0) v = 1;
        else             v = 0;
    end
endmodule