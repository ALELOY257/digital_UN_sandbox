%%{init: {'theme': 'dark', 'themeVariables': { 'primaryColor': '#1a1a1a'}}}%%
flowchart TD
    subgraph SPIDMA["SPIDMA Module"]
        direction TB
        
        subgraph SPI_Interface["SPI Interface"]
            direction LR
            SPI_PADS["SPI Pads\n(clk, mosi, miso, cs)"] --> SPIMaster
            SPIMaster["SPI Master\n(8MHz, 8-bit)"] -->|miso| BitCapture
        end
        
        subgraph BitCapture["Bit Capture Logic"]
            clk_prev["clk_prev Reg"] --> EdgeDetect
            EdgeDetect["Edge Detector"] -->|clock| ShiftReg["8-bit Shift Register"]
            ShiftReg -->|byte_ready| FIFO_In["FIFO Input"]
        end
        
        subgraph DataPath["Data Path"]
            FIFO["1024-byte SyncFIFO"] --> Converter["8→32 Converter"]
            Converter --> DMA_Writer["WishboneDMAWriter"]
        end
        
        subgraph Control["Control Logic"]
            CSR["CSR Registers:\n- control\n- status\n- dma_length"] --> FSM
            FSM["State Machine:\n- reset\n- idle\n- transfer"] -->|commands| DMA_Writer
        end
        
        SPIMaster -->|clk| BitCapture
        BitCapture -->|byte_ready| FIFO
        FIFO --> DataPath
        DataPath -->|wishbone| HyperRAM
        Control --> DataPath
    end