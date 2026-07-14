module bin2bcd_top #(
    parameter WIDTH=8,
    parameter SLICE_WIDTH = 4
)(
    input wire clk,
    input wire rst,
    input wire init,
    input wire [WIDTH-1:0] bcd_in,
    output wire [11:0] res, 
    output wire done
);
    wire LD, SHIN, SHRES, DECC;
    wire LD_2, LD_3, LD_4;
    wire v_1, v_2, v_3 ;
    wire z;
    wire [3:0] added_slice_11_8, added_slice_7_4, added_slice_3_0; 
    wire bcd_in_msb;
    wire replacing_bit; 

    assign replacing_bit = bcd_in_msb; 

    control_bin2bcd u_control(
        .clk(clk), .rst(rst), .init(init), .v_1(v_1), .v_2(v_2), .v_3(v_3), .z(z),
        .SHIN(SHIN), .SHRES(SHRES), .DECC(DECC),
        .LD(LD), .LD_2(LD_2) , .LD_3(LD_3) , .LD_4(LD_4),
        .done(done)
    );

    bcd_in_reg #(.WIDTH(WIDTH)) u_bcd_in(
        .clk(clk), .rst(rst), .LD(LD), .SHIN(SHIN), .bcd_in(bcd_in),
        .bcd_in_msb(bcd_in_msb)
    );

    res_reg #(.WIDTH(12)) u_res_reg(
        .clk(clk), .rst(rst), .LD(LD), .LD_2(LD_2) , .LD_3(LD_3), .LD_4(LD_4) , .SHRES(SHRES), .replacing_bit(replacing_bit),
        .added_slice_11_8(added_slice_11_8), .added_slice_7_4(added_slice_7_4), .added_slice_3_0(added_slice_3_0),
        .res_out(res)
    );

    comparator #(.WIDTH(SLICE_WIDTH)) comp_11_8(
        .a(res[11:8]), .b(4'd5),
        .v(v_1)
    );

    comparator #(.WIDTH(SLICE_WIDTH)) comp_7_4(
        .a(res[7:4]), .b(4'd5),
        .v(v_2)
    );

    comparator #(.WIDTH(SLICE_WIDTH)) comp_3_0(
        .a(res[3:0]), .b(4'd5),
        .v(v_3)
    );

    sumador #(.WIDTH(SLICE_WIDTH)) sum_11_8(
        .slice(res[11:8]), 
        .added_slice(added_slice_11_8)
    );

    sumador #(.WIDTH(SLICE_WIDTH)) sum_7_4(
        .slice(res[7:4]),
        .added_slice(added_slice_7_4)
    );

    sumador #(.WIDTH(SLICE_WIDTH)) sum_3_0(
        .slice(res[3:0]),
        .added_slice(added_slice_3_0)
    );

    contador #(.WIDTH(WIDTH)) u_contador(
        .clk(clk), .rst(rst), .LD(LD), .DECC(DECC), .init_val(8'd8),
        .z(z)
    );

endmodule