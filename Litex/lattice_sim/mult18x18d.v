// Behavioral model of ECP5 MULT18X18D for simulation
module MULT18X18D (
    input  [17:0] A, B,
    output [35:0] P,
    // Pipeline registers (ignored in behavioral model)
    input CLK0, CLK1, CLK2, CLK3,
    input CE0,  CE1,  CE2,  CE3,
    input RST0, RST1, RST2, RST3,
    input SIGNED,
    input [1:0] SOURCEA, SOURCEB,
    output [17:0] SRIA, SRIB,
    output [35:0] ROI, ROJ
);
    assign P   = A * B;
    assign ROI = 36'b0;
    assign ROJ = 36'b0;
    assign SRIA = 18'b0;
    assign SRIB = 18'b0;
endmodule