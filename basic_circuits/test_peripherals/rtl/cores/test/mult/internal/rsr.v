module rsr #(parameter WIDTH = 4) (
    input clk,
    input [WIDTH-1:0] in_B, 
    input shift, 
    input load, 
    output reg [WIDTH-1:0] s_B
);

    always @(posedge clk) begin 
        if (load)
            s_B <= in_B; 
        else if (shift)
            s_B <= s_B >> 1;
    end
endmodule