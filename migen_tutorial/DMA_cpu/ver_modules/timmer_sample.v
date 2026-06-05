// =============================================================================
// TIMMER SAMPLE MODULE
// =============================================================================

module timmer_sample (
    input  wire         clk,
    input  wire         reset,
    input  wire         st_tick_sample,
    input  wire [15:0]  sample_counter, // SPI data to send 
    output reg          tick_sample    // done count
);

    localparam INIT          = 3'b001;
    localparam WAIT_ST       = 3'b000;
    localparam COUNT         = 3'b010;
    localparam CHECK         = 3'b100;

    reg [15:0] tick_counter;

    reg [2:0] state;

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            tick_sample    <= 1'b0;
            tick_counter   <= 0;
            state           = INIT;
        end else begin
            case (state)
                INIT: begin
                    tick_sample   <= 1'b0;
                    tick_counter  <= 0;
                    if (st_tick_sample)
                        state = COUNT;
                    else 
                        state = INIT;
                end

                COUNT: begin
                    tick_counter <= tick_counter + 1;
                    if (tick_counter >= sample_counter) begin
                    //if (tick_counter >= 2170) begin
                        state          =  WAIT_ST;
                        tick_sample   <= 1'b1;
                        tick_counter  <= 0;
                    end
                    else begin
                        state          =  COUNT;
                        tick_sample   <= 1'b0;                
                    end
                    
                end

                WAIT_ST: begin
                    tick_sample   <= 1'b1;
                    tick_counter  <= 0;
                    if (st_tick_sample)
                        state = COUNT;
                    else 
                        state = WAIT_ST;
                end


                default: begin
                    state  = INIT;
                end
            endcase
        end
    end

endmodule