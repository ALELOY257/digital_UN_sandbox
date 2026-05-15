module mult_top(
    input clk,
    input rst, 
    input init, 
    input  [15:0] A, 
    input  [15:0] B, 
    output [RES_WIDTH-1:0]pp, 
    output done
    );
    parameter A_WIDTH = 16;
    parameter B_WIDTH = 16;
    parameter RES_WIDTH = A_WIDTH + B_WIDTH;

    wire shift, reset, add, z;
    wire [RES_WIDTH-1:0] w_A;
    wire [B_WIDTH-1:0] w_B;


    acc #(.WIDTH(RES_WIDTH)) acc_instance (
        .clk(clk), 
        .A(w_A),
        .add(add), 
        .rst(reset), 
        .pp(pp)
    );

    comp #(.WIDTH(B_WIDTH)) comp_instance (
        .B(w_B), 
        .z(z)
    );

    rsr #(.WIDTH(B_WIDTH)) rsr_instance (
        .clk(clk), 
        .in_B(B), 
        .shift(shift), 
        .load(reset), 
        .s_B(w_B)
    );

    lsr #(.WIDTH(A_WIDTH)) lsr_instance (
        .clk(clk), 
        .in_A({{B_WIDTH{1'b0}}, A}),
        .shift(shift), 
        .load(reset), 
        .s_A(w_A)
    );

    control_mult cm_instance (
        .clk(clk), 
        .rst(rst), 
        .lsb_B(w_B[0]), 
        .init(init), 
        .z(z),
        .done(done), 
        .sh(shift), 
        .reset(reset), 
        .add(add)
    );
    
endmodule