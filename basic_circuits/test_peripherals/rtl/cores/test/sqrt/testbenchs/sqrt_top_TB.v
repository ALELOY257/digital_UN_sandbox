`timescale 1ns / 1ps

module top_tb;

    reg        clk;
    reg        rst;
    reg        init;
    reg  [7:0] S_in;

    wire [3:0] Res_out;
    wire       done;

    top #(
        .INPUT_WIDTH(8) 
    ) uut (
        .clk(clk),
        .rst(rst),
        .init(init),
        .S_in(S_in),
        .Res_out(Res_out),
        .done(done)
    );

    always begin
        #10 clk = ~clk;
    end

    initial begin
        $dumpfile("sqrt_top_TB.vcd"); 
        $dumpvars(0, top_tb);            

        clk  = 0;
        rst  = 1;
        init = 0;
        S_in = 8'd0;

        #20;
        rst = 0;
        #20;

        // TEST CASE 1: Square Root of 25
        $display("[TB] Testing S = 25");
        S_in = 8'd25;
        init = 1;
        #20; 
        init = 0;


        @ (posedge done);
        #10; 
        $display("[TB] S = %d -> Root = %d (Expected: 5)", S_in, Res_out);
        #40; 

        // TEST CASE 2: Square Root of 64
        $display("[TB] Testing S = 64");
        S_in = 8'd64;
        init = 1;
        #20;
        init = 0;

        @ (posedge done);
        #10;
        $display("[TB] S = %d -> Root = %d (Expected: 8)", S_in, Res_out);
        #40;

        // Square Root of 7 (Expected: 2)
        $display("[TB] Testing S = 7");
        S_in = 8'd7;
        init = 1;
        #20;
        init = 0;

        @ (posedge done);
        #10;
        $display("[TB] S = %d -> Root = %d (Expected: 2)", S_in, Res_out);
        #40;

        //TEST CASE 4: Square Root of 125
        $display("[TB] Testing S = 125");
        S_in = 8'd125;
        init = 1;
        #20;
        init = 0;

        @ (posedge done);
        #10;
        $display("[TB] S = %d -> Root = %d (Expected: 11)", S_in, Res_out);
        #40;

        $display("[TB] All test cases completed successfully!");
        $finish;
    end

endmodule