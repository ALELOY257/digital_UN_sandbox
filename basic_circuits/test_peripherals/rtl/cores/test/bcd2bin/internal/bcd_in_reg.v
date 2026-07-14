module bcd_in_reg #(parameter WIDTH=12)(
    input clk,
    input rst,
    input LD,
    input LD1,
    input LD2,
    input LD3,
    input SHBCD,
    input [WIDTH-1:0]bcd_in,
    input wire [3:0] added_slice_11_8,
    input wire [3:0] added_slice_7_4,
    input wire [3:0] added_slice_3_0,
    output reg [WIDTH-1:0] bcd_reg_out
);

    reg [WIDTH-1:0] next;
    always @(negedge clk) begin
        if(rst)
            bcd_reg_out <= bcd_in;
        else if (LD)
            bcd_reg_out <= bcd_in;
        else if (SHBCD)
            bcd_reg_out <= bcd_reg_out >> 1;
        else begin
            next = bcd_reg_out;
            if (LD1) next[11:8] = added_slice_11_8;
            if (LD2) next[7:4] = added_slice_7_4;
            if (LD3) next[3:0] = added_slice_3_0;
            bcd_reg_out <= next;
        end
    end
endmodule