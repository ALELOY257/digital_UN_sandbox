module s_reg #(
    parameter WIDTH = 8
)(
    input  wire             clk,
    input  wire             rst,
    input  wire             LD,
    input  wire             SH_S,
    input  wire [WIDTH-1:0] s_in,
    output wire [1:0]       s_top_bits
);

    reg [WIDTH-1:0] r_s;

    assign s_top_bits = r_s[WIDTH-1:WIDTH-2];

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            r_s <= {WIDTH{1'b0}};
        end else if (LD) begin
            r_s <= s_in; 
        end else if (SH_S) begin
            r_s <= r_s << 2; 
        end
    end

endmodule