from migen import *
from migen.genlib.cdc import MultiReg
from litex.soc.interconnect.csr import *
from litex.soc.interconnect.csr_eventmanager import *
class Verilog_UART(Module,AutoCSR):
   def __init__(self, data):
   # Interfaz
      self.clk      = ClockSignal()
      self.rst      = ResetSignal()
      self.uart_txd = data.uart_txd
      self.uart_rxd = data.uart_rxd
   # registros solo lectura      
      self.rx_data  = CSRStatus(8)
      self.rx_avail = CSRStatus()
      self.rx_error = CSRStatus()
      self.tx_busy  = CSRStatus()
   # Registros solo escritura       
      self.rx_ack   = CSRStorage()
      self.tx_data  = CSRStorage(8)
      self.tx_wr    = CSRStorage()
   # Instanciación del módulo verilog     
      self.specials +=Instance("uart_transceiver", 
	         i_clk      = self.clk,
          	i_reset    = self.rst,
	         o_uart_txd = self.uart_txd,
            i_uart_rxd = self.uart_rxd,
            o_rx_data  = self.rx_data.status,
	         o_rx_avail = self.rx_avail.status,
	         o_rx_error = self.rx_error.status,
	         o_tx_busy  = self.tx_busy.status,
            i_rx_ack   = self.rx_ack.storage,
	         i_tx_data  = self.tx_data.storage,
	         i_tx_wr    = self.tx_wr.storage,
	   )	   
      self.submodules.ev = EventManager()
      self.ev.ok = EventSourceProcess()
      self.ev.finalize()
