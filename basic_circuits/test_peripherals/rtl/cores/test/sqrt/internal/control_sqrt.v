module state_machine (
    input  wire clk,
    input  wire rst,
    input  wire init,
    input  wire v,              
    input  wire z,              
    output reg  LD,
    output reg  SUBR,
    output reg  SH_REM,
    output reg  SH_RES,
    output reg  DECC,
    output reg  SH_S,
    output reg  replacing_bit,
    output reg  done
);

    localparam START      = 3'b000;
    localparam REMS       = 3'b001;
    localparam CHECKREM   = 3'b010;
    localparam RES1       = 3'b011;
    localparam RES0       = 3'b100;
    localparam CHECKCOUNT = 3'b101;
    localparam END        = 3'b110;

    reg [2:0] current_state, next_state;
    reg [4:0] done_count;

    always @(posedge clk) begin
        if (rst) begin
            current_state <= START;
        end else begin
            current_state <= next_state;
            if (current_state==END)
                done_count <= done_count + 1;
            else if (current_state==START)
                done_count <=0;
        end
    end

    always @(*) begin
        case (current_state)
            START: begin
                if (init) next_state = REMS;
                else      next_state = START;
            end
            
            REMS: begin
                next_state = CHECKREM;
            end
            
            CHECKREM: begin
                if (v) next_state = RES1; 
                else   next_state = RES0; 
            end
            
            RES1: begin
                next_state = CHECKCOUNT;
            end
            
            RES0: begin
                next_state = CHECKCOUNT;
            end
            
            CHECKCOUNT: begin
                if (z) next_state = END;  
                else   next_state = REMS;
            end
            
            END: begin
                if (done_count > 5'd28)
                    next_state = START;
                else 
                    next_state = END; 
            end
            
            default: next_state = START;
        endcase
    end

    always @(*) begin
        LD            = 0;
        SUBR          = 0;
        SH_REM        = 0;
        SH_RES        = 0;
        DECC          = 0;
        SH_S          = 0;
        replacing_bit = 0;
        done          = 0;

        case (current_state)
            START: begin
                LD = 1; 
            end
            
            REMS: begin
                SH_REM = 1; 
                SH_S   = 1; 
            end
            
            CHECKREM: begin
            end
            
            RES1: begin
                SUBR          = 1; 
                SH_RES        = 1; 
                replacing_bit = 1; 
            end
            
            RES0: begin
                SUBR          = 0; 
                SH_RES        = 1; 
                replacing_bit = 0; 
            end
            
            CHECKCOUNT: begin
                DECC = 1; 
            end
            
            END: begin
                done = 1; 
            end
        endcase
    end

endmodule