module blink (clk , rst, LED);
  input clk;
  input rst;
  output LED;

  reg [5:0] count;

assign LED = count[5];

always @(negedge clk)
  if (rst)
    count <= 0;
  else
    count <= count + 1;
endmodule
