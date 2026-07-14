module control_bcd2bin(
    input clk,
    input rst,
    input init,
    input v_1,
    input v_2,
    input v_3,
    input z,
    output reg SHBCD,
    output reg LD,
    output reg SHBIN,
    output reg DECC,
    output reg LD1,
    output reg LD2,
    output reg LD3,
    output reg done
);
    localparam START = 3'b000;
    localparam SHIFTREGS = 3'b001;
    localparam CHECKCOUNT = 3'b010;
    localparam FINISH = 3'b011;
    localparam CHECKDIGITS = 3'b100;
    localparam SUMDIGITS = 3'b101;

    reg [2:0] current_state, next_state;
    reg[4:0] done_count;

    always @(posedge clk) begin
        if (rst) begin
            current_state <= START;
            done_count <= 0;
        end
        else begin
            current_state <= next_state;
            if (current_state == FINISH)
                done_count <= done_count +1;
            else if (current_state == START)
                done_count <= 0;
        end
    end

    always @(*) begin
        case (current_state)
            START: begin
                if (init) next_state = SHIFTREGS;
                else next_state = START;
            end

            SHIFTREGS: begin
                next_state = CHECKCOUNT;
            end

            CHECKCOUNT: begin
                if (z) next_state = FINISH;
                else next_state = CHECKDIGITS; 
            end

            CHECKDIGITS: begin
                if (v_1 || v_2 || v_3) next_state = SUMDIGITS;
                else next_state = SHIFTREGS;
            end

            SUMDIGITS: begin
                next_state = SHIFTREGS;
            end

            FINISH: begin
                if (done_count > 5'd28) next_state = START;
                else next_state = FINISH;
            end

            default: next_state = START;
        endcase
    end

    always @(*) begin
        SHBCD = 0;
        LD = 0;
        SHBIN = 0;
        DECC = 0;
        LD1 = 0;
        LD2 = 0;
        LD3 = 0;
        done = 0;
        case (current_state)
            START: begin
                LD = 1;
            end

            SHIFTREGS: begin
                DECC =1;
                SHBIN = 1;
                SHBCD = 1;
            end

            CHECKCOUNT: begin

            end

            CHECKDIGITS: begin
                
            end

            SUMDIGITS: begin
                if (v_1) LD1 = 1;
                if (v_2) LD2 = 1;
                if (v_3) LD3 = 1;
            end

            FINISH: begin
                done = 1;
            end


        endcase
    end
endmodule