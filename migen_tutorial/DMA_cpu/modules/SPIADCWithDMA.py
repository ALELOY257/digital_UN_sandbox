from migen import *
from litex.soc.interconnect.csr import *
from litex.soc.interconnect import stream
from litex.soc.cores.spi import SPIMaster
from litex.soc.cores.dma import WishboneDMAReader
from litex.soc.cores.dma import WishboneDMAWriter
from litex.soc.interconnect import wishbone



from litex.gen import *
from litex.soc.interconnect.csr import *




class SPIADCWithDMA(LiteXModule):
    def __init__(self, platform, bus, fifo_depth=512, endianness="little"):
        self.bus = bus
        self.irq = Signal()
        
        # Submodules
        spi_fifo         = stream.SyncFIFO([("data", 8)], fifo_depth, buffered=True)
        converter        = stream.Converter(8, bus.data_width, reverse=True)
        self.submodules += spi_fifo, converter
        self.submodules.dma_writer  = WishboneDMAWriter(bus, with_csr=True, endianness=endianness)
        #SPI_ADC
        self.submodules.spi = SPIMaster(
            pads=platform.request("spi_adc"),
            data_width=8,
            sys_clk_freq=100e6,
            spi_clk_freq=1e6
        )
        # Flow
        start   = Signal()
        connect = Signal()
        self.comb += start.eq(self.spi.sink.valid & self.spi.sink.first)
        self.sync += [
            If(~self.dma_writer._enable.storage,
                connect.eq(0)
            ).Elif(start,
                connect.eq(1)
            )
        ]
        self.comb += [
            If(self.dma_writer._enable.storage & (start | connect),
                #conectar F
                self.spi.source.connect(spi_fifo.sink)
            ),
            # Conectar FIFO al DMA Writer
            spi_fifo.source.connect(converter.sink),
            converter.source.connect(self.dma_writer.sink),
        ]
        # IRQ / Generate IRQ on DMA done rising edge
        done_d = Signal()
        self.sync += done_d.eq(self.dma_writer._done.status)
        # IRQ / Generate IRQ on DMA done rising edge
        self.sync += done_d.eq(self.dma_writer._done.status)
        self.sync += self.irq.eq(self.dma_writer._done.status & ~done_d)

