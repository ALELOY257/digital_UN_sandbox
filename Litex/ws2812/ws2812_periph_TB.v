`timescale 1ns / 1ps
`define SIMULATION

module ws2812_periph_TB;
    reg       clk;
    reg       reset;
    reg       init_m;
    reg       rst_cmd;

    reg [23:0] w_data;
    reg [7:0]  w_address;
    reg        we_a;

    ws2812_periph uut( .clk(clk), .reset(reset), .init_m(init_m), .rst_cmd(rst_cmd), .w_data(w_data), .we_a(we_a), .w_address(w_address) );

    parameter PERIOD          = 20;
    parameter real DUTY_CYCLE = 0.5;
    parameter OFFSET          = 0;

    initial begin
        #OFFSET;
        forever begin
            clk = 1'b0;
            #(PERIOD-(PERIOD*DUTY_CYCLE)) clk = 1'b1;
            #(PERIOD*DUTY_CYCLE);
        end
    end

    task write_mem;
        input [23:0] data;
        input [7:0] address;
        begin
            @(negedge clk);
            w_data = data;
            w_address = address;
            we_a = 1;
            @(negedge clk);
            @(negedge clk);
            we_a = 0;
            @(negedge clk);
        end
    endtask

    integer    idx;
    initial begin : TEST_CASE
        $dumpfile("ws2812_periph_TB.vcd");
        $dumpvars(0, ws2812_periph_TB);
        for(idx = 0; idx < 64; idx = idx +1)  $dumpvars(0, ws2812_periph_TB.uut.mem0.MEM[idx]);
        #(6000000) $finish;
    end
    reg [23:0] data_tmp;
    reg [7:0]  addr_tmp;
    integer ii;

    initial begin
        #0 reset = 1; init_m = 0; rst_cmd = 0;
        @(negedge clk);
        reset = 0;
        @(negedge clk);
        init_m = 1;
        @(negedge clk);
        init_m = 0;
        wait(ws2812_periph_TB.uut.done == 1);
        repeat (20) @(negedge clk);

      for (ii=0; ii<17; ii=ii+1)
        begin
            data_tmp = ii * 2;
            addr_tmp = ii;
            write_mem(data_tmp, addr_tmp);
        end

        init_m = 1;
        repeat (4) @(negedge clk);
        init_m = 0;

    end

endmodule