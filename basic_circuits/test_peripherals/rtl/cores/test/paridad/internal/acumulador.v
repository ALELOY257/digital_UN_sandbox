module acumulador #(parameter WIDTH=8)(
    input clk,
    input rst,
    input ADDACC,
    output reg [WIDTH-1:0]parcheck
);
    always @(negedge clk) begin
        if (rst)
            parcheck <= {WIDTH{1'b0}};
        else if (ADDACC)
            parcheck <= parcheck + 1;
        
    end 
endmodule