module comp #(parameter WIDTH = 4)(B, z);
  input [WIDTH-1:0] B;
  output reg z;

  always@(*)
    if (B==0)
      z <= 1;
    else
      z <= 0;

endmodule