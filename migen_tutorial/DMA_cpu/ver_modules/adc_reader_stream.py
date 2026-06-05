from migen import *
from migen.genlib.cdc import MultiReg
from litex.soc.interconnect.csr import *
from litex.soc.interconnect.csr_eventmanager import *
from litex.soc.interconnect import stream

class ADC_STREAMER(Module,AutoCSR):
   def __init__(self, data):
   # Interfaz
        self.clk            = ClockSignal()
        self.reset          = ResetSignal()
    # ADC output Signals
        self.ncs            = data.ncs
        self.sclk           = data.sclk
        self.st_conv        = data.st_conv
        self.dout           = data.dout
        self.reset_ad       = data.reset_ad
    # ADC input Signals
        self.busy           = data.busy
        self.data_in        = data.data_in

    # Write only registers
        self.re_b           = CSRStorage()
        self.adr_b          = CSRStorage(16)
        self.sample_counter = CSRStorage(16)
    # SPI TX signals
        self.spi_tx_data    = CSRStorage(16)
        self.rstrb          = CSRStorage()
        self.st_capture     = CSRStorage()
    # Read only registers
        self.spi_rx_data    = CSRStatus(16)
        self.done_tx        = CSRStatus()
        self.done_capture   = Signal()
        self.dat_b          = Signal(16)
    # Instanciación del módulo verilog     
        self.specials +=Instance("adc_reader", 
                i_clk             = self.clk,
                i_reset          = self.reset,
                o_ncs            = self.ncs,
                o_sclk           = self.sclk,
                o_st_conv        = self.st_conv,
                o_dout           = self.dout,
                o_reset_ad       = self.reset_ad,
                i_busy           = self.busy,
                i_data_in        = self.data_in,

                o_done_capture   = self.done_capture,
                o_dat_b          = self.dat_b,


                i_spi_tx_data    = self.spi_tx_data.storage,
                i_rstrb          = self.rstrb.storage,
                i_st_capture     = self.st_capture.storage,

                o_spi_rx_data    = self.spi_rx_data.status,
                o_done_tx        = self.done_tx.status,
                i_re_b           = self.re_b.storage,
                i_adr_b          = self.adr_b.storage,
                i_sample_counter = self.sample_counter.storage,
        )	   
        self.submodules.ev = EventManager()
        self.ev.ok = EventSourceProcess()
        self.ev.finalize()

class StreamADC(Module,AutoCSR):
    def __init__(self, platform, data_width, adr_width, address=0x40500000):
        # Stream interfaces
        self.sink   = sink   = stream.Endpoint( [ ( "data", data_width ) ] )
        self.source = source = stream.Endpoint( [ ( "address", adr_width ), ( "data", data_width ) ] )
        addr = Signal(adr_width, reset=address)


        # # #

        self.submodules.adc_stream = adc_stream = ADC_STREAMER(platform.request("spi_adc",0))
        

        self.comb += [
            source.data.eq(adc_stream.dat_b),
            source.address.eq(address)
        ]


        self.sync += [
            # Make sure the data is valid}
            If(adc_stream.done_capture,
                #source.ready.eq(1),
                source.valid.eq(1),
                sink.ready.eq(1),
                sink.valid.eq(1),
                If(sink.valid & source.ready,
                    addr.eq(addr + 2),
                    # If this data is the last of this stream
                    If(sink.last,
                        addr.eq(address)
                    )
                ),
            ).Else(
                #source.ready.eq(0),
                source.valid.eq(0),
                sink.ready.eq(0),
                sink.valid.eq(0),
            )
        ]



# void read_samples(void){
# 	int i,j, address;
# 	uint32_t data;

# 	adc0_adc_stream_st_capture_write(1);
# 	adc0_adc_stream_st_capture_write(0);
#     while( !(adc0_adc_stream_done_capture_read() & 1 )  )


# 	adc0_adc_stream_re_b_write(1);
#     address = 0;
# 	for(j=0; j < 2048; j++){
# 		for(i = 0; i < 8; i ++){
# 		  adc0_adc_stream_adr_b_write(address);
# 		  if(i==2){
# 		    data=adc0_adc_stream_dat_b_read();
# 			write_memory_32( ( 0x40500000  + j*2 ) , (  data ) );
# 		  }
# 		  address ++;
# 		}
# 	}
# 	adc0_adc_stream_re_b_write(0);
# 	adc0_adc_stream_st_capture_write(1);

# //	printf("\e[1m !!!Voltage 0 !!!!:\e[0m\n");
# //	for(i = 0; i < 2048; i ++){
# //		printf("%d\n",   (int16_t )(( read_memory_32(0x40500000 + i*2)) & 0xffff)   );
# //	}
