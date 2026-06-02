module infer_latch (
    input  wire en,
    input  wire d,
    output reg  q
);
    always @(*) begin
        if (en)
            q = d;
    end
endmodule
