
module memory_writer #(
    parameter adr_width = 14
) (
    input  wire                     clk,
    input  wire                     reset,
    input  wire                     end_frame,
    input  wire                     st_capture,
    output reg                      mem_busy,
    output reg                      rb_sel,
    output reg  [adr_width-1:0]     address,
    output reg                      done_capture,
    output reg                      we_a
);

    // Estados de la máquina según el diagrama de flujo
    localparam INIT         = 2'b00;
    localparam WAIT_FRAME   = 2'b01;
    localparam WRITING      = 2'b10;
    localparam FINISH       = 2'b11;
    
    reg [1:0] state;
    reg end_frame_prev;
    wire end_frame_pulse;
    
    // Detección de flanco positivo de end_frame
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            end_frame_prev <= 1'b0;
        end else begin
            end_frame_prev <= end_frame;
        end
    end
    
    assign end_frame_pulse = end_frame & ~end_frame_prev;
    
    // Máquina de estados siguiendo exactamente el diagrama de flujo
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            rb_sel       <= 1'b0;
            address      <= {adr_width{1'b0}};
            mem_busy     <= 1'b0;
            we_a         <= 0;
            done_capture <= 0;
            state         = INIT;
        end else begin
            case (state)
                INIT: begin 
                    rb_sel       <= 1'b0;                    
                    address      <= {adr_width{1'b0}};
                    mem_busy     <= 1'b0;
                    done_capture <= 1'b0;
                    we_a         <= 0; 
                    if (st_capture)
                        state     = WAIT_FRAME;
                    else 
                        state     = INIT;
                end

                WAIT_FRAME: begin
                    done_capture <= 1'b0;
                    if (end_frame_pulse) begin
                        state         = WRITING;
                        we_a         <= 1'b1;
                        mem_busy     <= 1'b1;
                    end
                end
                
                WRITING: begin
                    address       <= address + 1'b1;
                    done_capture  <= 1'b0;
                    if (address[2:0] == 3'b111) begin
                        state      = FINISH;
                        mem_busy  <= 1'b0;
                        rb_sel    <= ~rb_sel;
                        we_a      <= 1'b0;
                    end else begin
                        we_a      <= 1'b1;
                        mem_busy  <= 1'b1;
                    end
                end
                
                FINISH: begin
                    if (address == 11'h000 ) begin
                        done_capture     <= 1'b1;
                        if (st_capture) begin
                            state         = WAIT_FRAME;
                            
                        end
                    end
                    else begin
                       state         = WAIT_FRAME;
                       done_capture <= 1'b0;
                    end
                end
                
                default: begin
                    state  = INIT;
                end
            endcase
        end
    end

endmodule
