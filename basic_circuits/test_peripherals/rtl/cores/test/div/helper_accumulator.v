module helper_accumulator #(parameter WIDTH = 8)(
    input clk,
    input rst,
    input shift,
    input ldhe,
    input ld,
    input replacing_value,
    input [WIDTH-1:0] sub_input,
    output reg [WIDTH-1:0] helper_out
);
    always @(posedge clk or posedge rst) begin
        if (rst) 
            helper_out <= {WIDTH{1'b0}};
        else if (ld)
            helper_out <= {WIDTH{1'b0}};
        else if (shift) 
            helper_out <= {helper_out[WIDTH-2:0], replacing_value};
        else if (ldhe)
            helper_out <= sub_input; 
    end
endmodule