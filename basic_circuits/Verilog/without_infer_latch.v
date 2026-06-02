module without_infer_latch (
    input  wire  en,
    input  wire  d,
    output reg   q
);
    always @(*) begin
        if (en)
            q = d;
        else
            q = 0;
    end
endmodule