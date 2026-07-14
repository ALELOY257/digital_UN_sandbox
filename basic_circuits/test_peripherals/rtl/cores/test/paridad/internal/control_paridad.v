module control_paridad(
    input clk,
    input rst,
    input v,
    input z,
    input init,
    output reg LD,
    output reg SH,
    output reg ADDACC,
    output reg DECC,
    output reg done
);
    localparam START = 3'b000;
    localparam CHECKPARLSB = 3'b001;
    localparam PARACC = 3'b010;
    localparam COUNTSHIFT = 3'b011;
    localparam CHECKCOUNT = 3'b100;
    localparam FINISH = 3'b101;

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
                if (init) next_state = CHECKPARLSB;
                else next_state=START;
            end

            CHECKPARLSB: begin
                if (v) next_state = PARACC;
                else next_state = COUNTSHIFT;
            end

            PARACC: begin
                next_state = COUNTSHIFT;
            end

            COUNTSHIFT: begin
                next_state = CHECKCOUNT;
            end

            CHECKCOUNT: begin 
                if (z) next_state = FINISH;
                else next_state = CHECKPARLSB;
            end

            FINISH: begin
                if (done_count > 5'd28) next_state = START;
                else next_state = FINISH;
            end

            default:  next_state = START;
        endcase
    end

    always @(*) begin
        LD = 0;
        SH = 0;
        ADDACC = 0;
        DECC = 0;
        done =0;
        case (current_state)
            START: begin
                LD = 1;
            end

            CHECKPARLSB: begin

            end

            PARACC: begin
                ADDACC =1;
            end

            COUNTSHIFT: begin
                SH =1;
                DECC =1;
            end

            CHECKCOUNT: begin 

            end

            FINISH: begin
                done =1;
            end


        endcase
    end
endmodule