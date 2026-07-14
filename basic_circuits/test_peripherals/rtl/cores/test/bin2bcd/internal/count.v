module contador #(parameter WIDTH=8)(
    input wire clk,
    input wire rst,
    input wire LD,
    input wire DECC,
    input wire [WIDTH-1:0] init_val,
    output wire z
);
    reg [WIDTH-1:0] count_reg;

    assign z = (count_reg == 4'd1) ? 1'b1 : 1'b0;

    always @(posedge clk) begin
        if (rst)
            count_reg <= {WIDTH{1'b0}};
        else if (LD)
            count_reg <= init_val;
        else if (DECC)
            count_reg <= count_reg - 1'b1;
    end
endmodule