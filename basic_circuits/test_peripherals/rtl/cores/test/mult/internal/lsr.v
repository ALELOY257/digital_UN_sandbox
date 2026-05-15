module lsr #(parameter WIDTH=4)(clk , in_A , shift , load , s_A);
  input clk;
  input [WIDTH-1:0]in_A;
  input load;
  input shift;
  output reg [WIDTH-1:0]s_A;

always @(posedge clk)
  if(load)
     s_A <= in_A ;
  else
   begin
    if(shift)
      s_A <= {s_A[WIDTH-2:0], 1'b0};
    else
      s_A <= s_A;
   end

endmodule