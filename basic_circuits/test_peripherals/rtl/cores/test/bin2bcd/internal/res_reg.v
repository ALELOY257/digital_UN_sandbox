module res_reg #(parameter WIDTH=12)(
    input wire clk,
    input wire rst,
    input wire LD,
    input wire LD_2,
    input wire LD_3,
    input wire LD_4,
    input wire [3:0] added_slice_11_8,
    input wire [3:0] added_slice_7_4,
    input wire [3:0] added_slice_3_0,
    input wire SHRES,
    input wire replacing_bit,
    output reg [WIDTH-1:0] res_out
);

    reg [WIDTH-1:0] next;

    always @(posedge clk) begin //tengo que testear esto, porque es para evitar una race condition
        if (rst)
            res_out <= {WIDTH{1'b0}};
        else if (LD)
            res_out <= {WIDTH{1'b0}};
        else if (SHRES)
            res_out <= {res_out[WIDTH-2:0], replacing_bit};
        else begin
            next = res_out;
            if (LD_2) next[11:8] = added_slice_11_8;
            if (LD_3) next[7:4]  = added_slice_7_4;
            if (LD_4) next[3:0]  = added_slice_3_0;
            res_out <= next;
        end
    end

endmodule