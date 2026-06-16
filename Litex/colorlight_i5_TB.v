`timescale 1ns / 1ps
`define SIMULATION

module colorlight_i5_TB();
// Testbench uses a 10 MHz clock
// Want to interface to 115200 baud UART
// 25000000 / 115200 = 217 Clocks Per Bit.
parameter tck              = 40;
parameter c_BIT_PERIOD     = 8680;

   reg       CLK;
   reg       RESET;
   reg       RXD;
   reg       TXD;

   colorlight_i5 uut(
    .clk25(CLK),
    .cpu_reset_n(!RESET),
    .serial_tx(TXD),
    .serial_rx(RXD)
   );
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


    // Inicialización de las señales de control
    initial begin
        #0   RXD   = 1;
        #0   RESET = 1;
        #80  RESET = 1;
        #160 RESET = 0;
    end

    integer idx; 
    initial begin

    $dumpfile("colorlight_i5_TB.vcd");
    $dumpvars(-1,colorlight_i5_TB);
    //for(idx = 0; idx < 32; idx = idx +1)  $dumpvars(0, top_tb.uut.\adc_reader.dpram0.ram[idx]);
    //$dumpvars(0, bench.uut.CPU.registerFile[10],bench);

    //for(idx = 0; idx < 50; idx = idx +1)  $dumpvars(0, bench.uut.dpram_p0.dpram0.ram[idx]);
    //$dumpvars(0, bench.uut.CPU.registerFile[10],bench);


    #(tck*5000000) $finish;
 end
 
 


/*





    // Transmisión serial de los datos



*/

endmodule   
 
