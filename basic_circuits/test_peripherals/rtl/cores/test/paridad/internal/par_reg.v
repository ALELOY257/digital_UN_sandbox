module par_reg #(parameter WIDTH=8)(
    input clk,
    input rst,
    input [WIDTH-1:0]par,
    input LD,
    input SH,
    output reg [WIDTH-1:0]par_reg
);

    always @(negedge clk) begin
        if (rst)
            par_reg <= {WIDTH{1'b0}};
        else if (LD)
            par_reg <= par;
        else if (SH)
            par_reg <= par_reg >> 1;
    end
endmodule