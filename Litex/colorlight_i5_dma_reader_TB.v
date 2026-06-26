`timescale 1ns / 1ps
`define SIMULATION

// Isolated WishboneDMAReader testbench.
//
// This TB instantiates the same generated SoC/firmware but disconnects the
// diagnostic question from the WS2812 loader by forcing the DMA stream output
// ready high. It answers: can WishboneDMAReader itself read all programmed
// words, assert source.last, and reach dma_done when downstream never stalls?
module colorlight_i5_dma_reader_TB();
    parameter tck        = 40;
    parameter sim_cycles = 100000;
    parameter enable_vcd = 1;

    reg  CLK;
    reg  RESET;
    reg  RXD;
    wire TXD;

    colorlight_i5 uut(
        .clk25(CLK),
        .cpu_reset_n(!RESET),
        .serial_tx(TXD),
        .serial_rx(RXD)
    );

    initial begin
        CLK = 1'b0;
        forever #(tck/2) CLK = ~CLK;
    end

    initial begin
        RXD   = 1'b1;
        RESET = 1'b1;
        #80;
        RESET = 1'b0;
    end

    // Ideal DMA stream sink: always ready. This bypasses downstream
    // converter/FIFO/WS2812-loader backpressure for the DMA source interface.
    initial begin
        force uut.disp0_dma_source_source_ready = 1'b1;
    end

    integer idx;
    initial begin
        if (enable_vcd) begin
            $dumpfile("colorlight_i5_dma_reader_TB.vcd");
            $dumpvars(0, colorlight_i5_dma_reader_TB.CLK);
            $dumpvars(0, colorlight_i5_dma_reader_TB.RESET);

            // CPU/bus context.
            $dumpvars(0, colorlight_i5_dma_reader_TB.uut.VexRiscv.lastStagePc);
            $dumpvars(0, colorlight_i5_dma_reader_TB.uut.basesoc_ibus_cyc);
            $dumpvars(0, colorlight_i5_dma_reader_TB.uut.basesoc_ibus_stb);
            $dumpvars(0, colorlight_i5_dma_reader_TB.uut.basesoc_ibus_ack);
            $dumpvars(0, colorlight_i5_dma_reader_TB.uut.basesoc_ibus_adr);
            $dumpvars(0, colorlight_i5_dma_reader_TB.uut.basesoc_dbus_cyc);
            $dumpvars(0, colorlight_i5_dma_reader_TB.uut.basesoc_dbus_stb);
            $dumpvars(0, colorlight_i5_dma_reader_TB.uut.basesoc_dbus_ack);
            $dumpvars(0, colorlight_i5_dma_reader_TB.uut.basesoc_dbus_we);
            $dumpvars(0, colorlight_i5_dma_reader_TB.uut.basesoc_dbus_adr);
            $dumpvars(0, colorlight_i5_dma_reader_TB.uut.basesoc_dbus_dat_w);
            $dumpvars(0, colorlight_i5_dma_reader_TB.uut.basesoc_dbus_dat_r);
            $dumpvars(0, colorlight_i5_dma_reader_TB.uut.socbushandler_request);
            $dumpvars(0, colorlight_i5_dma_reader_TB.uut.socbushandler_grant);
            $dumpvars(0, colorlight_i5_dma_reader_TB.uut.socbushandler_shared_ack);
            $dumpvars(0, colorlight_i5_dma_reader_TB.uut.socbushandler_slave_sel);

            // DMA control/status.
            $dumpvars(0, colorlight_i5_dma_reader_TB.uut.disp0_dma_base_storage);
            $dumpvars(0, colorlight_i5_dma_reader_TB.uut.disp0_dma_length_storage);
            $dumpvars(0, colorlight_i5_dma_reader_TB.uut.disp0_dma_enable_storage);
            $dumpvars(0, colorlight_i5_dma_reader_TB.uut.disp0_dma_done);
            $dumpvars(0, colorlight_i5_dma_reader_TB.uut.disp0_dma_offset1);
            $dumpvars(0, colorlight_i5_dma_reader_TB.uut.disp0_dma_length1);
            $dumpvars(0, colorlight_i5_dma_reader_TB.uut.basesoc_wishbonedmareader_state);

            // DMA address sink side and data source side.
            $dumpvars(0, colorlight_i5_dma_reader_TB.uut.disp0_dma_sink_sink_valid);
            $dumpvars(0, colorlight_i5_dma_reader_TB.uut.disp0_dma_sink_sink_ready);
            $dumpvars(0, colorlight_i5_dma_reader_TB.uut.disp0_dma_sink_sink_last);
            $dumpvars(0, colorlight_i5_dma_reader_TB.uut.disp0_dma_sink_sink_payload_address);
            $dumpvars(0, colorlight_i5_dma_reader_TB.uut.disp0_dma_source_source_valid);
            $dumpvars(0, colorlight_i5_dma_reader_TB.uut.disp0_dma_source_source_ready);
            $dumpvars(0, colorlight_i5_dma_reader_TB.uut.disp0_dma_source_source_last);
            $dumpvars(0, colorlight_i5_dma_reader_TB.uut.disp0_dma_source_source_payload_data);
            $dumpvars(0, colorlight_i5_dma_reader_TB.uut.disp0_dma_fifo_level);
            $dumpvars(0, colorlight_i5_dma_reader_TB.uut.disp0_dma_fifo_sink_valid);
            $dumpvars(0, colorlight_i5_dma_reader_TB.uut.disp0_dma_fifo_sink_ready);
            $dumpvars(0, colorlight_i5_dma_reader_TB.uut.disp0_dma_fifo_sink_last);
            $dumpvars(0, colorlight_i5_dma_reader_TB.uut.disp0_dma_fifo_source_valid);
            $dumpvars(0, colorlight_i5_dma_reader_TB.uut.disp0_dma_fifo_source_ready);
            $dumpvars(0, colorlight_i5_dma_reader_TB.uut.disp0_dma_fifo_source_last);

            // Wishbone master and SRAM target.
            $dumpvars(0, colorlight_i5_dma_reader_TB.uut.ws2812_dma_bus_cyc);
            $dumpvars(0, colorlight_i5_dma_reader_TB.uut.ws2812_dma_bus_stb);
            $dumpvars(0, colorlight_i5_dma_reader_TB.uut.ws2812_dma_bus_ack);
            $dumpvars(0, colorlight_i5_dma_reader_TB.uut.ws2812_dma_bus_we);
            $dumpvars(0, colorlight_i5_dma_reader_TB.uut.ws2812_dma_bus_adr);
            $dumpvars(0, colorlight_i5_dma_reader_TB.uut.ws2812_dma_bus_dat_r);
            $dumpvars(0, colorlight_i5_dma_reader_TB.uut.basesoc_ram_bus_ram_bus_cyc);
            $dumpvars(0, colorlight_i5_dma_reader_TB.uut.basesoc_ram_bus_ram_bus_stb);
            $dumpvars(0, colorlight_i5_dma_reader_TB.uut.basesoc_ram_bus_ram_bus_ack);
            $dumpvars(0, colorlight_i5_dma_reader_TB.uut.basesoc_ram_bus_ram_bus_adr);
            $dumpvars(0, colorlight_i5_dma_reader_TB.uut.basesoc_ram_adr);

            // A few SRAM words to confirm the firmware filled the source buffer.
            for (idx = 0; idx < 8; idx = idx + 1)
                $dumpvars(0, colorlight_i5_dma_reader_TB.uut.sram[idx]);
        end
    end

    integer dma_beats;
    integer dma_last_seen;
    integer dma_last_beat;
    integer dma_bus_acks;
    integer heartbeat;
    integer cycles_without_progress;
    integer last_progress_beats;
    integer last_progress_acks;

    initial begin
        dma_beats     = 0;
        dma_last_seen = 0;
        dma_last_beat = 0;
        dma_bus_acks  = 0;
        heartbeat     = 0;
        cycles_without_progress = 0;
        last_progress_beats     = 0;
        last_progress_acks      = 0;
    end

    always @(posedge uut.sys_clk) begin
        heartbeat = heartbeat + 1;

        if (uut.ws2812_dma_bus_cyc && uut.ws2812_dma_bus_stb && uut.ws2812_dma_bus_ack)
            dma_bus_acks = dma_bus_acks + 1;

        if (uut.disp0_dma_source_source_valid && uut.disp0_dma_source_source_ready) begin
            dma_beats = dma_beats + 1;
            if ((dma_beats < 8) || (dma_beats[4:0] == 5'd31) || (dma_beats >= 240) || uut.disp0_dma_source_source_last) begin
                $display("DMA_ISO_BEAT beat=%0d data=%08x source_last=%b sink_last=%b offset=%0d len_words=%0d bus_adr=%08x bus_ack=%b t=%0t",
                    dma_beats + 1,
                    uut.disp0_dma_source_source_payload_data,
                    uut.disp0_dma_source_source_last,
                    uut.disp0_dma_sink_sink_last,
                    uut.disp0_dma_offset1,
                    uut.disp0_dma_length1,
                    uut.ws2812_dma_bus_adr,
                    uut.ws2812_dma_bus_ack,
                    $time);
            end
            if (uut.disp0_dma_source_source_last) begin
                dma_last_seen = 1;
                dma_last_beat = dma_beats + 1;
                $display("DMA_ISO_LAST beat=%0d done=%b offset=%0d len_words=%0d bus_acks=%0d t=%0t",
                    dma_beats + 1,
                    uut.disp0_dma_done,
                    uut.disp0_dma_offset1,
                    uut.disp0_dma_length1,
                    dma_bus_acks,
                    $time);
            end
        end

        if (uut.disp0_dma_done) begin
            $display("DMA_ISO_DONE beats=%0d last_seen=%0d last_beat=%0d bus_acks=%0d offset=%0d len_words=%0d length_bytes=%0d t=%0t",
                dma_beats,
                dma_last_seen,
                dma_last_beat,
                dma_bus_acks,
                uut.disp0_dma_offset1,
                uut.disp0_dma_length1,
                uut.disp0_dma_length_storage,
                $time);
            $finish;
        end

        if (heartbeat[15:0] == 16'h0000) begin
            $display("DMA_ISO_HEART pc=%08x beats=%0d last_seen=%0d bus_acks=%0d done=%b state=%0d off=%0d len_words=%0d length_bytes=%0d sink_vrl=%b/%b/%b source_vrl=%b/%b/%b bus=%b/%b/%b adr=%08x req=%03b grant=%0d t=%0t",
                uut.VexRiscv.lastStagePc,
                dma_beats,
                dma_last_seen,
                dma_bus_acks,
                uut.disp0_dma_done,
                uut.basesoc_wishbonedmareader_state,
                uut.disp0_dma_offset1,
                uut.disp0_dma_length1,
                uut.disp0_dma_length_storage,
                uut.disp0_dma_sink_sink_valid,
                uut.disp0_dma_sink_sink_ready,
                uut.disp0_dma_sink_sink_last,
                uut.disp0_dma_source_source_valid,
                uut.disp0_dma_source_source_ready,
                uut.disp0_dma_source_source_last,
                uut.ws2812_dma_bus_cyc,
                uut.ws2812_dma_bus_stb,
                uut.ws2812_dma_bus_ack,
                uut.ws2812_dma_bus_adr,
                uut.socbushandler_request,
                uut.socbushandler_grant,
                $time);
        end

        if ((dma_beats != last_progress_beats) || (dma_bus_acks != last_progress_acks)) begin
            cycles_without_progress = 0;
            last_progress_beats = dma_beats;
            last_progress_acks  = dma_bus_acks;
        end else begin
            cycles_without_progress = cycles_without_progress + 1;
        end

        if ((uut.disp0_dma_enable_storage != 0) && (cycles_without_progress == 3000)) begin
            $display("DMA_ISO_STALL beats=%0d last_seen=%0d last_beat=%0d bus_acks=%0d done=%b state=%0d offset=%0d len_words=%0d length_bytes=%0d sink_vrl=%b/%b/%b source_vrl=%b/%b/%b fifo_level=%0d fifo_sink_vr=%b/%b fifo_source_vr=%b/%b bus=%b/%b/%b adr=%08x dbus=%b/%b/%b dbus_adr=%08x req=%03b grant=%0d shared_ack=%b ram=%b/%b/%b ram_adr=%08x t=%0t",
                dma_beats,
                dma_last_seen,
                dma_last_beat,
                dma_bus_acks,
                uut.disp0_dma_done,
                uut.basesoc_wishbonedmareader_state,
                uut.disp0_dma_offset1,
                uut.disp0_dma_length1,
                uut.disp0_dma_length_storage,
                uut.disp0_dma_sink_sink_valid,
                uut.disp0_dma_sink_sink_ready,
                uut.disp0_dma_sink_sink_last,
                uut.disp0_dma_source_source_valid,
                uut.disp0_dma_source_source_ready,
                uut.disp0_dma_source_source_last,
                uut.disp0_dma_fifo_level,
                uut.disp0_dma_fifo_sink_valid,
                uut.disp0_dma_fifo_sink_ready,
                uut.disp0_dma_fifo_source_valid,
                uut.disp0_dma_fifo_source_ready,
                uut.ws2812_dma_bus_cyc,
                uut.ws2812_dma_bus_stb,
                uut.ws2812_dma_bus_ack,
                uut.ws2812_dma_bus_adr,
                uut.basesoc_dbus_cyc,
                uut.basesoc_dbus_stb,
                uut.basesoc_dbus_ack,
                uut.basesoc_dbus_adr,
                uut.socbushandler_request,
                uut.socbushandler_grant,
                uut.socbushandler_shared_ack,
                uut.basesoc_ram_bus_ram_bus_cyc,
                uut.basesoc_ram_bus_ram_bus_stb,
                uut.basesoc_ram_bus_ram_bus_ack,
                uut.basesoc_ram_bus_ram_bus_adr,
                $time);
            $finish;
        end
    end

    initial begin
        #(tck*sim_cycles);
        $display("DMA_ISO_TIMEOUT beats=%0d last_seen=%0d last_beat=%0d bus_acks=%0d done=%b state=%0d offset=%0d len_words=%0d length_bytes=%0d sink_vrl=%b/%b/%b source_vrl=%b/%b/%b bus=%b/%b/%b adr=%08x req=%03b grant=%0d t=%0t",
            dma_beats,
            dma_last_seen,
            dma_last_beat,
            dma_bus_acks,
            uut.disp0_dma_done,
            uut.basesoc_wishbonedmareader_state,
            uut.disp0_dma_offset1,
            uut.disp0_dma_length1,
            uut.disp0_dma_length_storage,
            uut.disp0_dma_sink_sink_valid,
            uut.disp0_dma_sink_sink_ready,
            uut.disp0_dma_sink_sink_last,
            uut.disp0_dma_source_source_valid,
            uut.disp0_dma_source_source_ready,
            uut.disp0_dma_source_source_last,
            uut.ws2812_dma_bus_cyc,
            uut.ws2812_dma_bus_stb,
            uut.ws2812_dma_bus_ack,
            uut.ws2812_dma_bus_adr,
            uut.socbushandler_request,
            uut.socbushandler_grant,
            $time);
        for (idx = 0; idx < 8; idx = idx + 1)
            $display("DMA_ISO_SRAM[%0d]=%08x", idx, uut.sram[idx]);
        $finish;
    end
endmodule
