module contador #(
    parameter WIDTH = 5
)(
    input  wire             clk,
    input  wire             rst,
    input  wire             LD,
    input  wire             DECC,
    input  wire [WIDTH-1:0] init_val, 
    output wire             z         
);

    reg [WIDTH-1:0] count_reg;


    assign z = (count_reg == 4'd1) ? 1'b1 : 1'b0;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            count_reg <= {WIDTH{1'b0}};
        end else if (LD) begin
            count_reg <= init_val; 
        end else if (DECC) begin
            count_reg <= count_reg - 1'b1; 
        end
    end

endmodule