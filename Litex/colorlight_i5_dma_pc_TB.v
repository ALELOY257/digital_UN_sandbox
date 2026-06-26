`timescale 1ns / 1ps
`define SIMULATION

// Testbench mínimo para prueba rápida de avance del PC.
// No genera VCD y no inspecciona DMA/CSR: solo confirma si el CPU avanza
// y en qué PC se queda detenido.
module colorlight_i5_dma_pc_TB();
    parameter tck = 40;
    parameter max_sysclk_edges = 200000;

    reg CLK;
    reg RESET;
    reg RXD;
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
        RXD = 1'b1;
        RESET = 1'b1;
        #80;
        RESET = 1'b0;
    end

    integer n;
    reg [31:0] last_pc;
    integer same_pc_count;
    integer pc_print_count;

    initial begin
        n = 0;
        last_pc = 32'hxxxxxxxx;
        same_pc_count = 0;
        pc_print_count = 0;
    end

    always @(posedge uut.sys_clk) begin
        n = n + 1;

        if (uut.VexRiscv.lastStagePc === last_pc)
            same_pc_count = same_pc_count + 1;
        else begin
            same_pc_count = 0;
            last_pc = uut.VexRiscv.lastStagePc;
            pc_print_count = pc_print_count + 1;
            if (pc_print_count < 200) begin
                $display("PC_CHANGE n=%0d t=%0t pc=%08x dbus_cyc=%b dbus_stb=%b dbus_ack=%b dbus_adr=%08x grant=%0d req=%03b dma_en=%b dma_state=%0d dma_off=%0d loader_busy=%b loader_done=%b dma_done=%b",
                    n,
                    $time,
                    uut.VexRiscv.lastStagePc,
                    uut.basesoc_dbus_cyc,
                    uut.basesoc_dbus_stb,
                    uut.basesoc_dbus_ack,
                    uut.basesoc_dbus_adr,
                    uut.socbushandler_grant,
                    uut.socbushandler_request,
                    uut.disp0_dma_enable_storage,
                    uut.basesoc_wishbonedmareader_state,
                    uut.disp0_dma_offset1,
                    uut.disp0_loader_busy,
                    uut.disp0_loader_done,
                    uut.disp0_dma_done);
            end
        end

        if ((n[9:0] == 10'h000) || (same_pc_count == 1024)) begin
            $display("PC_MON n=%0d t=%0t pc=%08x same=%0d dbus_cyc=%b dbus_stb=%b dbus_ack=%b dbus_adr=%08x grant=%0d req=%03b dma_en=%b dma_state=%0d dma_off=%0d loader_busy=%b loader_done=%b dma_done=%b",
                n,
                $time,
                uut.VexRiscv.lastStagePc,
                same_pc_count,
                uut.basesoc_dbus_cyc,
                uut.basesoc_dbus_stb,
                uut.basesoc_dbus_ack,
                uut.basesoc_dbus_adr,
                uut.socbushandler_grant,
                uut.socbushandler_request,
                uut.disp0_dma_enable_storage,
                uut.basesoc_wishbonedmareader_state,
                uut.disp0_dma_offset1,
                uut.disp0_loader_busy,
                uut.disp0_loader_done,
                uut.disp0_dma_done);
        end

        if (same_pc_count == 4096) begin
            $display("PC_STUCK n=%0d t=%0t pc=%08x dbus_cyc=%b dbus_stb=%b dbus_ack=%b dbus_adr=%08x grant=%0d req=%03b dma_en=%b dma_state=%0d dma_off=%0d loader_busy=%b loader_done=%b dma_done=%b",
                n,
                $time,
                uut.VexRiscv.lastStagePc,
                uut.basesoc_dbus_cyc,
                uut.basesoc_dbus_stb,
                uut.basesoc_dbus_ack,
                uut.basesoc_dbus_adr,
                uut.socbushandler_grant,
                uut.socbushandler_request,
                uut.disp0_dma_enable_storage,
                uut.basesoc_wishbonedmareader_state,
                uut.disp0_dma_offset1,
                uut.disp0_loader_busy,
                uut.disp0_loader_done,
                uut.disp0_dma_done);
            $finish;
        end

        if (n == max_sysclk_edges) begin
            $display("PC_MON_DONE n=%0d t=%0t pc=%08x", n, $time, uut.VexRiscv.lastStagePc);
            $finish;
        end
    end
endmodule
