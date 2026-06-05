from migen import *
from migen.genlib.cdc import MultiReg
from litex.soc.interconnect.csr import *
from litex.soc.interconnect.csr_eventmanager import *

class Verilog_ADC_READER(Module,AutoCSR):
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
      self.dat_b          = CSRStatus(16)
      self.spi_rx_data    = CSRStatus(16)
      self.done_tx        = CSRStatus()
      self.done_capture   = CSRStatus()
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

             i_spi_tx_data    = self.spi_tx_data.storage,
             i_rstrb          = self.rstrb.storage,
             i_st_capture     = self.st_capture.storage,

	          o_dat_b          = self.dat_b.status,
             o_spi_rx_data    = self.spi_rx_data.status,
             o_done_tx        = self.done_tx.status,
             o_done_capture   = self.done_capture.status,
             i_re_b           = self.re_b.storage,
	          i_adr_b          = self.adr_b.storage,
             i_sample_counter = self.sample_counter.storage,
	   )	   
      self.submodules.ev = EventManager()
      self.ev.ok = EventSourceProcess()
      self.ev.finalize()
