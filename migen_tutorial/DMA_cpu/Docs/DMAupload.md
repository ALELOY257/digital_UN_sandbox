%%{init: {'theme': 'dark', 'themeVariables': { 'primaryColor': '#1a1a1a'}}}%%
flowchart TD
    subgraph DMAUpload["DMAUpload Module"]
        direction LR
        
        subgraph DMA_Control["DMA Control"]
            CSR["CSR Registers:\n- control\n- error\n- bytes_sent\n- packets_sent"] --> FSM
            FSM["State Machine:\n- idle\n- reading\n- flushing\n- done"] --> DMA_Reader
        end
        
        subgraph DataPath["Data Pipeline"]
            DMA_Reader["WishboneDMAReader\n(32-bit)"] --> Converter["32→8 Converter"]
            Converter --> FIFO["4096-byte SyncFIFO"]
            FIFO --> CDC["Clock Domain Crossing\n(sys→eth_rx)"]
            CDC --> UDP_TX["LiteEthStream2UDPTX"]
        end
        
        subgraph Monitoring["Monitoring"]
            Counter["Timeout Counter"] --> ErrorLogic
            ErrorLogic["Error Detection:\n- fifo_overflow\n- timeout\n- udp_error"] --> CSR
            Throughput["Throughput Calc"] --> CSR
        end
        
        DMA_Control --> DataPath
        DataPath -->|wishbone| HyperRAM
        DataPath --> Monitoring
        UDP_TX -->|UDP| Network["10.42.0.220:2000"]
    end