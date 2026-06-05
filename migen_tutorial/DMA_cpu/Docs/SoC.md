%%{init: {'theme': 'dark', 'themeVariables': { 'primaryColor': '#1a1a1a', 'clusterBkg': '#0d0d0d'}}}%%
classDiagram
    direction TB
    
    class BaseSoC {
        +CRG crg
        +HyperRAM hyperram
        +LiteEthPHYRMII ethphy
        +Etherbone etherbone
        +SPIDMA spi_dma
        +DMAUpload dma_upload
        +PWM pwm
    }
    
    class CRG {
        +Input: clk33
        +Input: user_btn_n
    }
    
    class HyperRAM {
        +8MB memory
        +Region: 0x40000000
    }
    
    class LiteEthPHYRMII {
        +eth_clocks
        +eth_pads
    }
    
    class Etherbone {
        +IP: 10.42.0.220
    }
    
    class SPIDMA {
        +SPIMaster spi
        +WishboneDMAWriter dma_writer
        +SyncFIFO fifo
        +stream.Converter converter
        +CSRStorage control
        +CSRStatus status
    }
    
    class DMAUpload {
        +WishboneDMAReader dma_reader
        +LiteEthStream2UDPTX udp_streamer
        +SyncFIFO fifo
        +CSRStorage control
        +Multiple CSRStatus registers
    }
    
    class PWM {
        +Output: user_led
    }
    
    BaseSoC --> CRG: Clock/Reset
    BaseSoC --> HyperRAM: Main Memory
    BaseSoC --> LiteEthPHYRMII: Ethernet PHY
    BaseSoC --> Etherbone: Ethernet Stack
    BaseSoC --> SPIDMA: SPI Data Acquisition
    BaseSoC --> DMAUpload: Network Data Upload
    BaseSoC --> PWM: LED Control
    
    SPIDMA --> HyperRAM: DMA Writes
    DMAUpload --> HyperRAM: DMA Reads
    
    note for SPIDMA "SPI ADC Interface:\n- 8MHz SPI clock\n- 32-bit DMA writes\n- 1024-byte FIFO"
    note for DMAUpload "UDP Streaming:\n- 10.42.0.220:2000\n- 4096-byte FIFO\n- Flow control"
    note for HyperRAM "Memory Map:\n- 0x40000000: Main RAM (8MB)\n- 0x30000000: DMA Buffers (1MB)"

