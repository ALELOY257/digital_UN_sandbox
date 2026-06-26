`timescale 1ns / 1ps
`define SIMULATION

module ws2812_streamer_generated_TB;
    reg sys_clk = 1'b0;
    reg sys_rst = 1'b1;

    wire dout;

    // Ports generated from LiteX CSRs. Names are assigned by Migen because the
    // original CSR objects are all named storage/re/status internally.
    reg  storage   = 1'b0;
    reg  storage_1 = 1'b0;
    wire status;

    reg         sink_valid = 1'b0;
    wire        sink_ready;
    reg  [31:0] sink_payload_data = 32'h00000000;

    reg  storage_2 = 1'b0;
    reg  re        = 1'b0;
    wire status_1;
    wire status_2;

    ws2812_streamer_top dut (
        .dout(dout),
        .storage(storage),
        .storage_1(storage_1),
        .status(status),
        .sink_valid(sink_valid),
        .sink_ready(sink_ready),
        .sink_payload_data(sink_payload_data),
        .storage_2(storage_2),
        .re(re),
        .status_1(status_1),
        .status_2(status_2),
        .sys_clk(sys_clk),
        .sys_rst(sys_rst)
    );

    always #10 sys_clk = ~sys_clk;

    task stream_word;
        input [31:0] word;
        begin
            @(negedge sys_clk);
            sink_payload_data = word;
            sink_valid = 1'b1;
            wait(sink_ready == 1'b1);
            @(posedge sys_clk);
            @(negedge sys_clk);
            sink_valid = 1'b0;
            sink_payload_data = 32'h00000000;
        end
    endtask

    integer idx;
    initial begin
        $dumpfile("ws2812_streamer_generated_TB.vcd");
        $dumpvars(-1, ws2812_streamer_generated_TB);
        for (idx = 0; idx < 16; idx = idx + 1)
            $dumpvars(0, ws2812_streamer_generated_TB.dut.ws2812_periph.mem0.MEM[idx]);
    end

    initial begin
        repeat (4) @(negedge sys_clk);
        sys_rst = 1'b0;

        // Start stream loader: pulse loader.start.re.
        @(negedge sys_clk);
        re = 1'b1;
        @(negedge sys_clk);
        re = 1'b0;
        repeat (8) @(negedge sys_clk);
        storage = 1'b1;
        @(negedge sys_clk)
        storage = 1'b0;
        wait(ws2812_streamer_generated_TB.dut.status == 1);
            stream_word(32'h00111111);
        stream_word(32'h00222222);
        stream_word(32'h00333333);
        stream_word(32'h00444444);
        stream_word(32'h00555555);
        stream_word(32'h00666666);
        stream_word(32'h00777777);
        stream_word(32'h00888888);
        repeat (8) @(negedge sys_clk);
        @(negedge sys_clk);
        re = 1'b1;
        @(negedge sys_clk);
        re = 1'b0;
        repeat (8) @(negedge sys_clk);
        storage = 1'b1;
        repeat (2) @(negedge sys_clk);
        storage = 1'b0;
        repeat (25000000) @(negedge sys_clk);
        $finish;
    end
endmodule
