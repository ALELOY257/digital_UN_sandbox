// =============================================================================
// SPI CONTROL MODULE
// =============================================================================

module spi_driver (
    input  wire         clk,
    input  wire         reset,
    input  wire         busy,           // Señal busy del ADC
    input  wire         mem_busy,       // Señal busy del memory writer
    input  wire [15:0]  spi_tx_data,    // SPI data to send 
    input  wire         rstrb,          // SPI Tx enable
    input  wire         sdin,           // SPI MISO signal
    input               st_capture,     // Enable continous capture
    input  wire         done_capture,   // Capture RAM full
    input  wire         tick_sample,    
    output              ncs,            // Chip select (activo bajo)
    output wire         sclk,           // SPI clock
    output reg          rb_en,          // Register bank enable
    output reg          end_frame,      // End of frame signal
    output              dout,
    output reg          reset_ad,
    output reg          st_conv,
    output reg          done_tx,        // SPI transmisión done
    output reg          st_tick_sample, 
    output reg [15:0]   spi_rx_data     // SPI data received
);

    // Parámetros de la máquina de estados
    localparam IDLE          = 4'b0000;
    localparam WAIT_BUSY     = 4'b0001;
    localparam SPI_ACTIVE    = 4'b0010;
    localparam COUNT_BITS    = 4'b0011;
    localparam SWITCH_BANK   = 4'b0100;
    localparam CHECK_MEM     = 4'b0101;
    localparam ST_CONV       = 4'b0110;
    localparam ST_INIT       = 4'b0111;
    localparam WAIT_INIT_END = 4'b1000;
    localparam ST_INIT2      = 4'b1001;
    localparam WAIT_TICK     = 4'b1010;




    localparam START         = 3'b001;
    localparam WAIT_STRB     = 3'b000;
    localparam SEND          = 3'b010;
    localparam CHECK         = 3'b100;

  

    // Registros internos
    reg [3:0] state, next_state;
    reg [2:0] state_tx;
    reg [3:0] bit_count;
    reg busy_prev;
    wire busy_rising;
    reg sclk_en;
    reg sclk_en_tx;
    reg ncs_rx;



    // Registros para la transmisión
    reg [5:0]  snd_bitcount;
    reg [15:0] cmd_addr;
    reg [5:0]  div_counter;
    reg csn_tx;
    

    // Detección de flanco de subida de busy
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            busy_prev <= 1'b0;
        end else begin
            busy_prev <= busy;
        end
    end
    
    assign busy_rising = busy & ~busy_prev;


    // Máquina de estados - Lógica secuencial
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            state <= ST_INIT;
            reset_ad <= 1;
        end else begin
            reset_ad <= 0;
            state <= next_state;
        end
    end

    // Máquina de estados - Lógica combinacional
    always @(*) begin
        next_state = state;
        
        case (state)
            ST_INIT: begin
                next_state =  ST_INIT2;
            end

            ST_INIT2: begin
                next_state =  WAIT_INIT_END;
            end


            WAIT_INIT_END: begin
                if ( (st_capture == 1) )
                   next_state = WAIT_TICK;
                else
                   next_state = WAIT_INIT_END;  
            end

            WAIT_TICK: begin
                if(tick_sample)
                   next_state = ST_CONV;
                else
                   next_state = WAIT_TICK;
            end

            ST_CONV: begin
                if ( & (done_capture == 0) ) begin
                   next_state = WAIT_BUSY;
                end
                else begin
                   next_state = WAIT_INIT_END;  
                end         
            end

            WAIT_BUSY: begin
                if (busy) begin
                    next_state = WAIT_BUSY;
                end else begin
                    next_state = SPI_ACTIVE;
                end
            end

            SPI_ACTIVE: begin
                next_state = COUNT_BITS;
            end
            
            COUNT_BITS: begin
                if (bit_count == 4'd15) begin
                    next_state = SWITCH_BANK;
                end else begin
                    next_state = COUNT_BITS;
                end
            end
            
            SWITCH_BANK: begin
                next_state = CHECK_MEM;
            end
            
            CHECK_MEM: begin
                if (rb_en && mem_busy) begin
                    next_state = CHECK_MEM;
                end else begin
                    next_state = WAIT_TICK;
                end
            end
            
            default: begin
                next_state = WAIT_TICK;
            end
        endcase
    end

    // Lógica de salidas y registros
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            // SPI_CONTROL: Inicialización
            rb_en          <= 1'b0;          // RB_en = 0
            bit_count      <= 4'b0;      // bit_count = 0
            end_frame      <= 1'b0;      // end_frame = 0
            ncs_rx         <= 1'b1;            // nCS inactivo (alto)
            sclk_en        <= 1'b0;
            st_conv        <= 1'b0;
            st_tick_sample <= 0;

        end else begin
            case (state)
            
                ST_INIT: begin
                    bit_count      <= 4'b0;      // bit_count = 0
                    end_frame      <= 1'b0;      // end_frame = 0
                    ncs_rx         <= 1'b1;            // nCS inactivo (alto)
                    sclk_en        <= 1'b0;
                    st_conv        <= 1'b0;
                    st_tick_sample <= 0;
                end

                ST_INIT2: begin
                    bit_count      <= 4'b0;      // bit_count = 0
                    end_frame      <= 1'b0;      // end_frame = 0
                    ncs_rx         <= 1'b1;            // nCS inactivo (alto)
                    sclk_en        <= 1'b0;
                    st_conv        <= 1'b0;
                    st_tick_sample <= 1;
                end

                WAIT_TICK: begin
                    bit_count      <= 4'b0;      // bit_count = 0
                    end_frame      <= 1'b0;      // end_frame = 0
                    ncs_rx         <= 1'b1;            // nCS inactivo (alto)
                    sclk_en        <= 1'b0;
                    st_conv        <= 1'b0;
                    st_tick_sample <= 1;                    
                end


                ST_CONV: begin
                    bit_count      <= 4'b0;      // bit_count = 0
                    end_frame      <= 1'b0;      // end_frame = 0
                    ncs_rx         <= 1'b1;            // nCS inactivo (alto)
                    sclk_en        <= 1'b0;
                    st_conv        <= 1'b1;  
                    st_tick_sample <= 0;              
                end

                WAIT_BUSY: begin
                    bit_count      <= 4'b0;      // bit_count = 0
                    end_frame      <= 1'b0;      // end_frame = 0
                    ncs_rx         <= 1'b1;            // nCS inactivo (alto)
                    sclk_en        <= 1'b0;
                    st_conv        <= 1'b0; 
                    st_tick_sample <= 0;
                end
                
                SPI_ACTIVE: begin
                    ncs_rx         <= 1'b0;
                    sclk_en        <= 1'b1; 
                    end_frame      <= 1'b0; 
                    bit_count      <= 4'b0;
                    st_conv        <= 1'b0;
                    st_tick_sample <= 0;
                end
                
                COUNT_BITS: begin
                    bit_count      <= bit_count + 1'b1;
                    sclk_en        <= 1'b1; 
                    ncs_rx         <= 1'b0; 
                    st_conv        <= 1'b0; 
                    st_tick_sample <= 0;                   
                    if (bit_count == 4'd15) begin
                        ncs_rx    <= 1'b1;
                        sclk_en   <= 1'b0; 
                    end
                end
                
                SWITCH_BANK: begin
                    // RB_en = not(RB_en)
                    rb_en          <= ~rb_en;
                    ncs_rx         <= 1'b1;
                    sclk_en        <= 0;
                    end_frame      <= 1'b1;
                    st_conv        <= 1'b0;
                    st_tick_sample <= 0;
                end
                
                CHECK_MEM: begin
                    // Verificar RB_en=1 & mem_busy=1
                    if (rb_en && mem_busy) begin
                        end_frame <= 1'b1;  // Generar end_frame
                    end
                    sclk_en        <= 0;
                    st_conv        <= 1'b0;
                    st_tick_sample <= 0;
                    // Volver a IDLE en el siguiente ciclo
                end
                
                default: begin
                    rb_en          <= 1'b0;
                    bit_count      <= 4'b0; 
                    ncs_rx         <= 1'b1;
                    sclk_en        <= 1'b0;
                    st_conv        <= 1'b0;
                    end_frame      <= 1'b0;
                    st_tick_sample <= 0;
                end
            endcase
        end
    end


/*
  write_ad7606c_reg(0x6F, 0x00);     // read ID Status to enter to register mode 
  write_ad7606c_reg(0x02, 0x18);     // Enable 8 bit serial 
*/




always @(posedge clk) begin
    if (reset) begin
      state_tx   = START;
      csn_tx     <= 1; 
      cmd_addr   <= 0;
      sclk_en_tx <= 0;
      done_tx    <= 0;
    end else begin
    case(state_tx)
      START:begin
        csn_tx       <= 1'b1;
        snd_bitcount <= 6'd0;
        state_tx     <= WAIT_STRB;
        sclk_en_tx   <= 0;   
        done_tx      <= 0;   
      end

      WAIT_STRB: begin
        sclk_en_tx <= 0;
        done_tx    <= 0;
        csn_tx     <= 1'b1;
        snd_bitcount <= 6'd16;
        if (rstrb) begin
          cmd_addr     <= spi_tx_data;
          state_tx      = SEND;
          sclk_en_tx <= 1;
          csn_tx     <= 1'b0;
        end
        else begin
          state_tx      = WAIT_STRB;
        end
      end

      SEND: begin
        sclk_en_tx    <= 1;
        done_tx       <= 0;
        csn_tx        <= 1'b0;            
        
        cmd_addr      <= {cmd_addr[14:0],1'b1};
        spi_rx_data   <= {spi_rx_data[14:0],sdin};
        if(snd_bitcount == 1) begin
            state_tx      = START;
            done_tx      <= 1;
            csn_tx       <= 1'b1;
            snd_bitcount <= 6'd0;
            sclk_en_tx   <= 0;   
        end
        else begin
            csn_tx       <= 1'b0;
            sclk_en_tx   <= 1;   
            done_tx      <= 0; 
            state_tx     = SEND;
            snd_bitcount  <= snd_bitcount - 1'b1;
        end;

      end

       default: begin 
          done_tx    <= 0;
          csn_tx     <= 1'b1;
          sclk_en_tx <= 0;
          state_tx    = START;
       end
    
    endcase
  end
end





//assign done_tx = 1;


assign dout  = cmd_addr[15];
assign sclk =  clk & (sclk_en | sclk_en_tx);
assign ncs  = ncs_rx & csn_tx;



endmodule
