// sim_pll.v - Modelo behavioral de EHXPLLL para simulación
module EHXPLLL (
    input  CLKI,
    input  RST,
    input  STDBY,
    output CLKOP,
    output CLKOS,
    output CLKOS2,
    output CLKOS3,
    output LOCK,
    output INTLOCK,
    input  REFCLK,
    input  CLKFB,
    output CLKINTFB
);
    // Parámetros ignorados en simulación
    parameter CLKFB_DIV     = 1;
    parameter CLKI_DIV      = 1;
    parameter CLKOP_DIV     = 10;
    parameter CLKOP_CPHASE  = 0;
    parameter CLKOP_FPHASE  = 0;
    parameter CLKOP_ENABLE  = "ENABLED";
    parameter CLKOS_DIV     = 10;
    parameter CLKOS_CPHASE  = 0;
    parameter CLKOS_FPHASE  = 0;
    parameter CLKOS_ENABLE  = "ENABLED";
    parameter CLKOS2_DIV    = 1;
    parameter CLKOS2_CPHASE = 0;
    parameter CLKOS2_FPHASE = 0;
    parameter CLKOS2_ENABLE = "ENABLED";
    parameter CLKOS3_DIV    = 1;
    parameter CLKOS3_CPHASE = 0;
    parameter CLKOS3_FPHASE = 0;
    parameter CLKOS3_ENABLE = "DISABLED";
    parameter FEEDBK_PATH   = "INT_OS2";
    parameter PLLRST_ENA    = "DISABLED";
    parameter STDBY_ENABLE  = "DISABLED";
    parameter FRACN_ENABLE  = "DISABLED";

    // LOCK se afirma después de un tiempo de lock simulado
    reg lock_r = 0;
    initial begin
        #200;        // 200 ns de lock time simulado
        lock_r = 1;
    end
    assign LOCK = lock_r & ~RST;

    // CLKOP: replica CLKI con período fijo = 60 MHz → 16.667 ns
    // Ajusta HALF_PERIOD a tu sys_clk_freq
    localparam real HALF_PERIOD_OP  = 8.333;  // 60 MHz
    localparam real HALF_PERIOD_OS  = 8.333;  // 60 MHz (sys_ps, misma freq)
    localparam real HALF_PERIOD_OS2 = 8.333;  // feedback

    reg clkop_r  = 0;
    reg clkos_r  = 0;
    reg clkos2_r = 0;

    always #(HALF_PERIOD_OP)  clkop_r  = ~clkop_r;
    always #(HALF_PERIOD_OS)  clkos_r  = ~clkos_r;
    always #(HALF_PERIOD_OS2) clkos2_r = ~clkos2_r;

    assign CLKOP   = (RST) ? 1'b0 : clkop_r;
    assign CLKOS   = (RST) ? 1'b0 : clkos_r;
    assign CLKOS2  = (RST) ? 1'b0 : clkos2_r;
    assign CLKOS3  = 1'b0;
    assign INTLOCK = lock_r;
    assign CLKINTFB = clkos2_r;

endmodule
// USRMCLK - SPI flash MCLK primitive (behavioral stub)
module USRMCLK (
    input USRMCLKI,
    input USRMCLKTS
);
    // En simulación no hay flash real, stub vacío es suficiente
endmodule

// ODDRX1F - DDR output register (behavioral)
module ODDRX1F (
    input  D0,
    input  D1,
    input  SCLK,
    input  RST,
    output Q
);
    reg q_r;
    always @(posedge SCLK or posedge RST)
        if (RST) q_r <= 1'b0;
        else     q_r <= D0;
    always @(negedge SCLK or posedge RST)
        if (RST) q_r <= 1'b0;
        else     q_r <= D1;
    assign Q = q_r;
endmodule

