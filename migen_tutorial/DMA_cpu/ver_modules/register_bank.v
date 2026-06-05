module register_bank (
  input         clk,
  input  [7:0] data_in,
  input         en,
  input  [2:0]  addr,
  output wire  [15:0] data_out  
);

    reg [15:0] RegisterBank [7:0];
    always@(posedge clk) begin
        if (en) begin
            RegisterBank[0] <= {RegisterBank[0][14:0], data_in[0]};
            RegisterBank[1] <= {RegisterBank[1][14:0], data_in[1]};
            RegisterBank[2] <= {RegisterBank[2][14:0], data_in[2]};
            RegisterBank[3] <= {RegisterBank[3][14:0], data_in[3]};
            RegisterBank[4] <= {RegisterBank[4][14:0], data_in[4]};
            RegisterBank[5] <= {RegisterBank[5][14:0], data_in[5]};
            RegisterBank[6] <= {RegisterBank[6][14:0], data_in[6]};
            RegisterBank[7] <= {RegisterBank[7][14:0], data_in[7]};
        end
    end
    assign data_out = RegisterBank[addr];

endmodule