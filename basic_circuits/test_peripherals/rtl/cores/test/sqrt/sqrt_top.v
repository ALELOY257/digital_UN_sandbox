module sqrt_top #(
    parameter INPUT_WIDTH = 8,
    parameter ROOT_WIDTH  = INPUT_WIDTH / 2,
    parameter MATH_WIDTH  = ROOT_WIDTH + 2
)(
    input  wire                   clk,
    input  wire                   rst,
    input  wire                   init,
    input  wire [INPUT_WIDTH-1:0] S_in,
    output wire [ROOT_WIDTH-1:0]  Res_out,
    output wire                   done
);

    wire LD, SUBR, SH_REM, SH_RES, DECC, SH_S, replacing_bit;
    wire v, z;

    wire [1:0]             s_top_bits;
    wire [ROOT_WIDTH-1:0]  res_val;
    wire [INPUT_WIDTH-1:0] remainder_val;
    wire [INPUT_WIDTH-1:0] sub_out;

    assign Res_out = res_val;

    wire [MATH_WIDTH-1:0]  helper_6bit     = {res_val, 2'b01};
    wire [INPUT_WIDTH-1:0] helper_extended = { {(INPUT_WIDTH - MATH_WIDTH){1'b0}}, helper_6bit };

    state_machine u_control (
        .clk(clk), .rst(rst), .init(init), .v(v), .z(z),
        .LD(LD), .SUBR(SUBR), .SH_REM(SH_REM), .SH_RES(SH_RES),
        .DECC(DECC), .SH_S(SH_S), .replacing_bit(replacing_bit), .done(done)
    );

    s_reg #(.WIDTH(INPUT_WIDTH)) u_s_reg (
        .clk(clk), .rst(rst), .LD(LD), .SH_S(SH_S), .s_in(S_in), .s_top_bits(s_top_bits)
    );

    remainder_reg #(.WIDTH(INPUT_WIDTH)) u_remainder_reg (
        .clk(clk), .rst(rst), .LD(LD), .SH_REM(SH_REM), .SUBR(SUBR),
        .s_top_bits(s_top_bits), .sub_data_in(sub_out), .remainder_out(remainder_val)
    );

    res_reg #(.WIDTH(ROOT_WIDTH)) u_res_reg (
        .clk(clk), .rst(rst), .LD(LD), .SH_RES(SH_RES), .replacing_bit(replacing_bit), .res_out(res_val)
    );

    comparator #(.WIDTH(INPUT_WIDTH)) u_data_comp (
        .a(remainder_val), .b(helper_extended), .v(v)
    );

    restador #(.WIDTH(INPUT_WIDTH)) u_restador (
        .a(remainder_val), .b(helper_extended), .sub_out(sub_out)
    );

    contador #(.WIDTH(4)) u_counter (
        .clk(clk), .rst(rst), .LD(LD), .DECC(DECC), .init_val(4'd4), .z(z)
    );

endmodule