module res_reg #(
    parameter WIDTH = 4
)(
    input  wire             clk,
    input  wire             rst,
    input  wire             LD,
    input  wire             SH_RES,
    input  wire             replacing_bit,
    output reg  [WIDTH-1:0] res_out
);

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            res_out <= {WIDTH{1'b0}};
        end else if (LD) begin
            res_out <= {WIDTH{1'b0}}; 
        end else if (SH_RES) begin
            res_out <= {res_out[WIDTH-2:0], replacing_bit};
        end
    end

endmodule