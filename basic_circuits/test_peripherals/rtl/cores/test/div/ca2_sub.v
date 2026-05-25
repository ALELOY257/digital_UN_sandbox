module ca2_sub #(parameter WIDTH = 8)(
    input [WIDTH-1:0] divisor,
    input [WIDTH-1:0] helper,
    output reg [WIDTH-1:0] ca2_res
);
    always @(*) begin
        ca2_res = helper - divisor; 
    end
endmodule