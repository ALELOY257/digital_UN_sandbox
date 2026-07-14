module bin_res_reg #(parameter WIDTH=10)(
    input clk,
    input rst,
    input bcdlsb,
    input SHBIN,
    input LD,
    output reg [WIDTH-1:0] bin_out
);
    always @(negedge clk) begin
        if (rst)
            bin_out <= {WIDTH{1'b0}};
        else if (LD) 
            bin_out <= {WIDTH{1'b0}};
        else if (SHBIN)
            bin_out <= {bcdlsb, bin_out[WIDTH-1:1]};
        
        
    end
endmodule 