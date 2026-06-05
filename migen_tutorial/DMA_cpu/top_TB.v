module top_tb();
// Testbench uses a 10 MHz clock
// Want to interface to 115200 baud UART
// 25000000 / 115200 = 217 Clocks Per Bit.
parameter tck              = 40;
parameter c_BIT_PERIOD     = 8680;

   reg       CLK;
   reg       i;
   reg       RESET; 
   wire      LEDS;
   reg       RXD = 1'b1;
   wire      TXD;
   reg       spi_adc0_busy;
   reg [7:0] spi_adc0_data_in;
   wire      st_conv;
   wire spi_adc0_ncs;
   wire spi_adc0_sclk;


   top uut(
     .clk33(CLK),
     .user_btn_n(!RESET),
     .user_led0(LEDS),
     .serial_rx(RXD),
     .serial_tx(TXD),
     .spi_adc0_busy(spi_adc0_busy),
     .spi_adc0_data_in(spi_adc0_data_in),
     .spi_adc0_ncs(),
     .spi_adc0_dout(),
     .spi_adc0_st_conv(st_conv),
     .spi_adc0_sclk()
   );


    // Tabla de seno precalculada (65536 muestras, 16 bits)
    reg [15:0] sine_table [0:65535];

    reg [15:0] bit_counter;           // Contador de bits
    reg [3:0] delay_counter;
    reg [7:0] sample_counter;        // Contador de muestras
    integer j;

    // Generación de clock principal
    initial begin
        CLK = 0;
        forever #(tck/2) CLK = ~CLK; // 1MHz clock
    end

  // Takes in input byte and serializes it 
  task UART_WRITE_BYTE;
    input [7:0] i_Data;
    integer     ii;
    begin
       
      // Send Start Bit
      RXD <= 1'b0;
      #(c_BIT_PERIOD);
      #1000;
       
       
      // Send Data Byte
      for (ii=0; ii<8; ii=ii+1)
        begin
          RXD <= i_Data[ii];
          #(c_BIT_PERIOD);
        end
       
      // Send Stop Bit
      RXD <= 1'b1;
      #(c_BIT_PERIOD);
     end
  endtask // UART_WRITE_BYTE

    // Inicialización de la tabla de seno
    initial begin
            for (j = 0; j < 65536; j = j + 1) begin
                // Seno normalizado a 16 bits (0-65536)
                sine_table[j] = $rtoi(32767.5 + 32767.5 * $sin(2 * 3.14159 * j / 256));
            end
    end

    // Inicialización de las señales de control
    initial begin
        #0   spi_adc0_busy <= 0;
        #0   RXD   = 1;
        #0   RESET = 1;
        #80  RESET = 1;
        #160 RESET = 0;
    end

    
    // Simulación de la señal busy: tiempo de conversión del ADC
    always @(posedge st_conv) begin
        #1   spi_adc0_busy <= 1;
        #200 spi_adc0_busy <= 0;
    end


    always @(negedge CLK or negedge RESET) begin
        if (RESET) begin
            spi_adc0_data_in <= 8'b0;
            bit_counter      <= 0;
            delay_counter    <= 15;

        end else begin
            // Extraer un bit de cada onda seno
            spi_adc0_data_in[0] <= sine_table[bit_counter + 0][delay_counter];
            spi_adc0_data_in[1] <= sine_table[bit_counter + 1][delay_counter];
            spi_adc0_data_in[2] <= sine_table[bit_counter + 2][delay_counter];
            spi_adc0_data_in[3] <= sine_table[bit_counter + 3][delay_counter];
            spi_adc0_data_in[4] <= sine_table[bit_counter + 4][delay_counter];
            spi_adc0_data_in[5] <= sine_table[bit_counter + 5][delay_counter];
            spi_adc0_data_in[6] <= sine_table[bit_counter + 6][delay_counter];
            spi_adc0_data_in[7] <= sine_table[bit_counter + 7][delay_counter];
            if (top_tb.uut.spi_adc0_ncs  == 0) begin
                delay_counter <= delay_counter - 1;
            end
            if (( top_tb.uut.\adc_reader.mem_wr0.end_frame_prev & top_tb.uut.\adc_reader.mem_wr0.end_frame ) == 1  ) begin
                bit_counter <= bit_counter + 1;
            end
        end
    end

  
       integer idx; 
   initial begin

    $dumpfile("top_TB.vcd");
    $dumpvars(-1,top_tb);
    //for(idx = 0; idx < 32; idx = idx +1)  $dumpvars(0, top_tb.uut.\adc_reader.dpram0.ram[idx]);
    //$dumpvars(0, bench.uut.CPU.registerFile[10],bench);

    //for(idx = 0; idx < 50; idx = idx +1)  $dumpvars(0, bench.uut.dpram_p0.dpram0.ram[idx]);
    //$dumpvars(0, bench.uut.CPU.registerFile[10],bench);

    #(tck*5000000000) $finish;
 end
 
 


/*





    // Transmisión serial de los datos



*/

endmodule   
 
