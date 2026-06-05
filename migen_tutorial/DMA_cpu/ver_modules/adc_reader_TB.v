module adc_reader_tb;
parameter tck              = 40;
parameter c_BIT_PERIOD     = 8680;

reg  [7:0]   data_in;
reg          clk, reset, busy;
wire         ncs;
wire         sclk;
reg          re_b;
reg  [12:0]  adr_b;
wire [15:0]  dat_b;
reg [15:0]   sin_dat;
reg  [15:0]  spi_tx_data;
reg          rstrb; 
reg          init; 
reg          st_capture;
wire         done_tx;


 adc_reader uut (
    .data_in(data_in),

    .clk(clk),
    .reset(reset),
    .busy(busy),
    .ncs(ncs),
    .sclk(sclk),
	.re_b(re_b),
	.adr_b(adr_b),
	.dat_b(dat_b),
    .spi_tx_data(spi_tx_data),
    .rstrb(rstrb), 
    .st_capture(st_capture)
 );
    
    // Señales del testbench
    reg rst_n;
    reg [2:0] wave_select;           // Selector de onda actual
    reg [15:0] bit_counter;           // Contador de bits
    reg [3:0] delay_counter;
    reg [7:0] sample_counter;        // Contador de muestras
    //reg [15:0] count;
   
    // Tabla de seno precalculada (65536 muestras, 16 bits)
    reg [15:0] sine_table [0:65535];
    
    // Variables para cálculo de índices
    integer i, j;
    integer phase_offset;
    integer sine_index;
    
    // Generación de clock principal
    initial begin
        clk = 0;
        forever #500 clk = ~clk; // 1MHz clock
    end
    
    
    // Inicialización de la tabla de seno
    initial begin
        for (i = 0; i < 65536; i = i + 1) begin
            sine_table[i] = $rtoi(32767.5 + 32767.5 * $sin(2 * 3.14159 * i / 65536));
        end
    end
    
    // Reset y inicialización
    initial begin
        reset          = 1;
        wave_select    = 0;
        bit_counter    = 0;
        delay_counter  = 15;
        sample_counter = 0;
        data_in        = 8'b0;
        busy           = 0;      
        st_capture     = 0;
        #1000;
        reset          = 0;

    end
    // Transmisión serial de los datos
    always @(posedge clk or negedge rst_n) begin
        if (reset) begin
            data_in     <= 8'b0;
            wave_select <= 0;
            bit_counter <= 0;
            adr_b       <= -16;
            re_b        <= 0;

        end else begin
 
            // Extraer un bit de cada onda seno
            data_in[0] <= sine_table[bit_counter + 0][delay_counter];
            data_in[1] <= 0 ;// sine_table[bit_counter + 1][delay_counter];
            data_in[2] <= 0 ;//sine_table[bit_counter + 2][delay_counter];
            data_in[3] <= 0 ;//sine_table[bit_counter + 3][delay_counter];
            data_in[4] <= 0 ;//sine_table[bit_counter + 4][delay_counter];
            data_in[5] <= 0 ;//sine_table[bit_counter + 5][delay_counter];
            data_in[6] <= 0 ;//sine_table[bit_counter + 6][delay_counter];
            data_in[7] <= 0 ;//sine_table[bit_counter + 7][delay_counter];
            sin_dat  <= sine_table[bit_counter];

`ifdef SYNTH
	        if (adc_reader_tb.uut.\spi0.ncs_rx  == 0) begin
`else
	        if (adc_reader_tb.uut.spi0.ncs_rx  == 0) begin
`endif
            delay_counter <= delay_counter - 1;
            end
`ifdef SYNTH
            if (( adc_reader_tb.uut.\mem_wr0.end_frame_prev & adc_reader_tb.uut.\mem_wr0.end_frame ) == 1  ) begin
`else
            if (( adc_reader_tb.uut.mem_wr0.end_frame_prev & adc_reader_tb.uut.mem_wr0.end_frame ) == 1  ) begin
`endif
                bit_counter <= bit_counter + 1;
                adr_b       <= adr_b + 8;
                re_b        <= 1;
            end
        end
    end



    initial begin
    #0  init   = 0;
        rstrb  = 0;

    #2000  if( ( init == 0 ) ) begin
        spi_tx_data = 16'h0218;
        @(posedge clk); rstrb = 1;
        @(posedge clk); rstrb = 0;
    end
    repeat (16)@(posedge clk); rstrb = 1;
    @(posedge clk)spi_tx_data = 16'h0219;
    @(posedge clk); rstrb = 0;
    repeat (16)@(posedge clk);
    init = 1;
    @(posedge clk); st_capture = 1;
    @(posedge clk); st_capture = 1;
    @(posedge clk); st_capture = 0;
    # 174000000 
    @(posedge clk); st_capture = 1;
    @(posedge clk); st_capture = 1;
    @(posedge clk); st_capture = 0;

    # 366000000 
    @(posedge clk); st_capture = 1;
    @(posedge clk); st_capture = 1;
    @(posedge clk); st_capture = 0;

`ifdef SYNTH
     #1000000000; // Simular por 1ms
`else
     #1000000000;
`endif
        $display("Simulación completada");
        $finish;
    end

integer idx;
initial begin
  $dumpfile("adc_reader_TB.vcd");
  $dumpvars(-1, adc_reader_tb);
`ifndef SYNTH
   $dumpvars(0, adc_reader_tb.uut.reg_bank0.RegisterBank[0]);
   $dumpvars(0, adc_reader_tb.uut.reg_bank1.RegisterBank[0]);
   for(idx = 0; idx < 32; idx = idx +1)  $dumpvars(0, adc_reader_tb.uut.dpram0.ram[idx]);
//  for(idx = 0; idx < 8; idx = idx +1)   $dumpvars(0,  adc_reader_tb.sine_table[idx]);
`endif
end


endmodule

