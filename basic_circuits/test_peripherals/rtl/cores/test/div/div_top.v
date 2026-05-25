module div_top #(parameter WIDTH=8)(
    input clk,
    input rst,
    input init,
    input [WIDTH-1:0] dividend,
    input [WIDTH-1:0] divisor,
    output [(2*WIDTH)-1:0] res,
    output done
);
    localparam RES_WIDTH = 2*WIDTH;

    wire replacing_bit, LD, DECC, SHHE, SHRES, SHDI, LDHE, v, z;
    wire [WIDTH-1:0] helper;
    wire [WIDTH-1:0] ca2_res;
    wire [WIDTH-1:0] dividend_wire;

    control_divisor control(
        .clk(clk), .rst(rst), .init(init), .v(v), .z(z),
        .replacing_bit(replacing_bit), .LD(LD), .DECC(DECC), 
        .SHHE(SHHE), .SHRES(SHRES), .SHDI(SHDI), .LDHE(LDHE), .done(done)
    );

    helper_accumulator #(WIDTH) helper_reg_inst(
        .clk(clk), .rst(rst), .shift(SHHE), .ldhe(LDHE), .ld(LD),
        .replacing_value(dividend_wire[WIDTH-1]), 
        .sub_input(ca2_res), .helper_out(helper)
    );

    lsr #(WIDTH) dividend_shift(
        .clk(clk), .load(LD), .shift(SHDI), .dividend(dividend),
        .dividend_out(dividend_wire)
    );

    ca2_sub #(WIDTH) ca2sub(
        .divisor(divisor), .helper(helper),
        .ca2_res(ca2_res)
    );

    comp_helper #(WIDTH) helpercomparator(
        .reg_ca2(ca2_res), .v(v)
    );

    reg [RES_WIDTH-1:0] res_reg;
    always @(posedge clk or posedge rst) begin
        if (rst)          res_reg <= 0;
        else if (LD)      res_reg <= 0;
        else if (SHRES)   res_reg <= {res_reg[RES_WIDTH-2:0], replacing_bit};
    end
    assign res = res_reg;

    reg [WIDTH-1:0] count_out;
    always @(posedge clk or posedge rst) begin
        if (rst)         count_out <= 0;
        else if (LD)     count_out <= WIDTH; 
        else if (DECC)   count_out <= count_out - 1;
    end
    assign z = (count_out == 0);

endmodule