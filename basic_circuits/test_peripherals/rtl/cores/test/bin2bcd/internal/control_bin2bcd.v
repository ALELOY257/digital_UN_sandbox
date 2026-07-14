module control_bin2bcd(
    input wire clk,
    input wire rst,
    input wire init,
    input wire v_1,
    input wire v_2,
    input wire v_3,
    input wire z,
    output reg LD,
    output reg LD_2,
    output reg LD_3,
    output reg LD_4,
    output reg SHIN,
    output reg SHRES,
    output reg DECC,
    output reg done
);
    localparam START = 3'b000;
    localparam CHECKDIGITS = 3'b001;
    localparam SUMDIGITS = 3'b010;
    localparam SHIFTREGS = 3'b011;
    localparam CHECKCOUNT = 3'b100;
    localparam END = 3'b101;

    reg [2:0] current_state, next_state;
    reg [4:0] done_count;

    always @(posedge clk) begin
        if (rst)
            current_state <= START;
        else begin
            current_state <= next_state;
            if (current_state == END)
                done_count <= done_count +1;
            else if (current_state == START)
                done_count <= 0;
        end
    end

    always @(*) begin
        case (current_state)
            START: begin
                if(init) next_state = CHECKDIGITS;
                else    next_state = START;
            end

            CHECKDIGITS: begin
                if (v_1 || v_2 || v_3) next_state = SUMDIGITS;
                else next_state = SHIFTREGS;    
            end

            SUMDIGITS: begin
                next_state = SHIFTREGS;
            end

            SHIFTREGS: begin
                next_state = CHECKCOUNT;
            end

            CHECKCOUNT: begin
                if (z) next_state= END;
                else next_state=CHECKDIGITS;
            end

            END: begin
                if (done_count > 5'd28) next_state = START; //la misma nota de antes, cambiar valor para sintetizar en fpga
                else  next_state = END;
            end

            default: next_state = START;
        endcase
    end

    always @(*) begin
        LD = 0;
        LD_2 = 0;
        LD_3 = 0;
        LD_4 = 0;
        SHIN = 0;
        SHRES  = 0;
        DECC = 0;
        done=0;

        case (current_state)
            START: begin
                LD=1;
            end

            CHECKDIGITS: begin

            end

            SUMDIGITS: begin
                if (v_1) LD_2=1;
                if (v_2) LD_3=1;
                if (v_3) LD_4=1;
            end

            SHIFTREGS: begin
                SHIN = 1;
                SHRES = 1;
            end

            CHECKCOUNT: begin
                DECC =1;
            end

            END: begin
                done = 1;
            end
        endcase
    end
endmodule