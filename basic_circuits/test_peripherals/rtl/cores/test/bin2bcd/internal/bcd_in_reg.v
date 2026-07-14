module bcd_in_reg #(parameter WIDTH = 8)(
    input wire clk,
    input wire rst,
    input wire LD,
    input wire SHIN,
    input wire [WIDTH-1:0] bcd_in,
    output wire bcd_in_msb
);

    reg [WIDTH-1:0] r_s;

    assign bcd_in_msb = r_s[WIDTH-1];

    always @(posedge clk) begin
        if (rst)
            r_s <= {WIDTH{1'b0}};
        else if (LD)
            r_s <= bcd_in;
        else if (SHIN)
            r_s <= r_s << 1;
    end
endmodule