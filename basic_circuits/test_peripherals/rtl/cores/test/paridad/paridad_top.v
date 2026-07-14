module paridad_top #(parameter WIDTH=8)(
    input clk,
    input rst,
    input init,
    input [WIDTH-1:0]par,
    output wire res,
    output wire done
);
    wire v, z;
    wire LD, SH, ADDACC, DECC;
    wire [WIDTH-1:0]par_reg, parcheck;

    assign res = parcheck[0];  

    control_paridad u_control(
        .clk(clk), .rst(rst), .v(v), .z(z), .init(init),
        .LD(LD), .SH(SH), .ADDACC(ADDACC), .DECC(DECC),
        .done(done)
    );

    par_reg #(.WIDTH(WIDTH)) u_par_reg(
        .clk(clk), .rst(rst), .par(par), .LD(LD), .SH(SH),
        .par_reg(par_reg)
    );

    acumulador u_acumulador(
        .clk(clk), .rst(rst), .ADDACC(ADDACC),
        .parcheck(parcheck)
    );

    comp u_comp(
        .a(par_reg[0]), .b(1'd1),
        .v(v)
    );

    count u_count(
        .clk(clk), .rst(rst), .LD(LD), .DECC(DECC), .init_val(WIDTH),
        .z(z)
    );

endmodule