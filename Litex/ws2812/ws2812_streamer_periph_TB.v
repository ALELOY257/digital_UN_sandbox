`timescale 1ns / 1ps
`define SIMULATION

// Testbench to observe the complete external write path:
//   stream-like source -> WS2812StreamLoader-equivalent signals -> ws2812_periph.mem0
//
// Migen's simulator cannot look inside the Verilog Instance("ws2812_periph").
// This pure Verilog TB instantiates ws2812_periph directly, exposes stream_valid,
// stream_ready, stream_data, we_a, w_address, w_data, and dumps uut.mem0.MEM[].
module ws2812_streamer_periph_TB;
    reg clk = 1'b0;
    reg reset = 1'b1;
    reg init_m = 1'b0;
    reg rst_cmd = 1'b0;

    // Stream side, equivalent to LiteX stream.Endpoint([("data", 32)]).
    reg         stream_valid = 1'b0;
    wire        stream_ready;
    reg  [31:0] stream_data  = 32'h00000000;

    // Loader state/write port signals connected to ws2812_periph.
    reg         loader_start = 1'b0;
    reg         loader_busy  = 1'b0;
    reg         loader_done  = 1'b0;
    reg  [7:0]  loader_addr  = 8'h00;

    wire        we_a;
    wire [7:0]  w_address;
    wire [23:0] w_data;
    reg         write_we      = 1'b0;
    reg  [7:0]  write_address = 8'h00;
    reg  [23:0] write_data    = 24'h000000;
    wire        dout;
    wire        done;

    localparam integer N_LEDS = 8;

    assign stream_ready = loader_busy;
    assign we_a         = write_we;
    assign w_address    = write_address;
    assign w_data       = write_data;

    ws2812_periph uut (
        .clk       (clk),
        .reset     (reset),
        .init_m    (init_m),
        .rst_cmd   (rst_cmd),
        .w_data    (w_data),
        .w_address (w_address),
        .we_a      (we_a),
        .dout      (dout),
        .done      (done)
    );

    always #10 clk = ~clk;  // 50 MHz simulation clock.

    // Same state machine as WS2812StreamLoader.
    always @(posedge clk) begin
        write_we <= 1'b0;
        if (reset) begin
            loader_addr <= 8'h00;
            loader_busy <= 1'b0;
            loader_done <= 1'b0;
            write_address <= 8'h00;
            write_data <= 24'h000000;
        end else if (loader_start) begin
            loader_addr <= 8'h00;
            loader_busy <= 1'b1;
            loader_done <= 1'b0;
            write_address <= 8'h00;
            write_data <= 24'h000000;
        end else if (loader_busy) begin
            if (stream_valid & stream_ready) begin
                write_we <= 1'b1;
                write_address <= loader_addr;
                write_data <= stream_data[23:0];
                if (loader_addr == (N_LEDS - 1)) begin
                    loader_addr <= 8'h00;
                    loader_busy <= 1'b0;
                    loader_done <= 1'b1;
                end else begin
                    loader_addr <= loader_addr + 1'b1;
                end
            end
        end
    end

    task send_pixel;
        input [31:0] pixel;
        begin
            @(negedge clk);
            stream_data  = pixel;
            stream_valid = 1'b1;
            @(negedge clk);
            $display("t=%0t stream_valid=%0d stream_ready=%0d we_a=%0d w_address=%0d w_data=%06x stream_data=%08x mem[%0d]=%06x",
                $time, stream_valid, stream_ready, we_a, w_address, w_data, stream_data,
                w_address, uut.mem0.MEM[w_address]);
            stream_valid = 1'b0;
            stream_data  = 32'h00000000;
        end
    endtask

    integer idx;
    initial begin
        $dumpfile("ws2812_streamer_periph_TB.vcd");
        $dumpvars(0, ws2812_streamer_periph_TB);
        // Dump first video-memory locations explicitly so GTKWave can show them.
        for (idx = 0; idx < 16; idx = idx + 1)
            $dumpvars(0, ws2812_streamer_periph_TB.uut.mem0.MEM[idx]);
    end

    initial begin
        repeat (4) @(negedge clk);
        reset = 1'b0;
        @(negedge clk);

        // Pulse loader_start, equivalent to CSR start.re.
        loader_start = 1'b1;
        @(negedge clk);
        loader_start = 1'b0;

        send_pixel(32'h00112233);
        send_pixel(32'h00445566);
        send_pixel(32'h00778899);
        send_pixel(32'h00aabbcc);
        send_pixel(32'h00010203);
        send_pixel(32'h00040506);
        send_pixel(32'h00070809);
        send_pixel(32'h000a0b0c);

        repeat (6) @(negedge clk);
        $display("Final MEM[0]=%06x", uut.mem0.MEM[0]);
        $display("Final MEM[1]=%06x", uut.mem0.MEM[1]);
        $display("Final MEM[2]=%06x", uut.mem0.MEM[2]);
        $display("Final MEM[3]=%06x", uut.mem0.MEM[3]);
        $display("Final MEM[4]=%06x", uut.mem0.MEM[4]);
        $display("Final MEM[5]=%06x", uut.mem0.MEM[5]);
        $display("Final MEM[6]=%06x", uut.mem0.MEM[6]);
        $display("Final MEM[7]=%06x", uut.mem0.MEM[7]);
        $finish;
    end
endmodule
