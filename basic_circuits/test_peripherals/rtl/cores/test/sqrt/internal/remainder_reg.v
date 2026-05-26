module remainder_reg #(
    parameter WIDTH = 8
)(
    input  wire             clk,
    input  wire             rst,
    input  wire             LD,
    input  wire             SH_REM,
    input  wire             SUBR,
    input  wire [1:0]       s_top_bits,
    input  wire [WIDTH-1:0] sub_data_in,
    output reg  [WIDTH-1:0] remainder_out
);

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            remainder_out <= {WIDTH{1'b0}};
        end else if (LD) begin
            remainder_out <= {WIDTH{1'b0}}; 
        end else if (SUBR) begin
            remainder_out <= sub_data_in; 
        end else if (SH_REM) begin
            remainder_out <= {remainder_out[WIDTH-3:0], s_top_bits};
        end
    end

endmodule