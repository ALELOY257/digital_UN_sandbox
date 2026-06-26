#include <stdint.h>
#include <generated/csr.h>

#define WS2812_HW_LEDS 256
#define TEST_WORDS     256

static volatile uint32_t ws2812_buffer[TEST_WORDS] __attribute__((aligned(4)));

static void dma_sim_wait(unsigned int cycles)
{
    volatile unsigned int i;
    for (i = 0; i < cycles; i++) {
        __asm__ volatile("nop");
    }
}

 static void fill_ws2812_buffer(uint32_t base)
{
    unsigned int i;
    for (i = 0; i < 5; i++) {
        uint32_t r = (base + i) & 0xff;
        uint32_t g = (base + (i << 1)) & 0xff;
        uint32_t b = (base + (i << 2)) & 0xff;
        ws2812_buffer[i] = (r << 16) | (g << 8) | b;
    }
}

static void load_ws2812_video_ram_with_dma(void)
{
    // Stop DMA before programming it.
    disp0_dma_enable_write(0);
    disp0_dma_loop_write(0);
    // Phase 1: load WS2812 video RAM through DMA.
    disp0_loader_start_write(1);
    disp0_dma_base_write((uint32_t)ws2812_buffer);
    disp0_dma_length_write(WS2812_HW_LEDS * 4);
    disp0_dma_enable_write(1);

    while (disp0_loader_done_read() == 0) {
        dma_sim_wait(10);
    }
    while (disp0_dma_done_read() == 0) {
        dma_sim_wait(10);
    }
    disp0_dma_enable_write(0);
}
 

int main(void)
{
    uint32_t frame = 0x10;
    unsigned int i;
    while (1) {
        fill_ws2812_buffer(frame);
        load_ws2812_video_ram_with_dma();
        disp0_init_write(1);
        disp0_init_write(0);
        while (disp0_done_read() == 0) {}

            frame += 0x20;
            dma_sim_wait(1000);
        }
    return 0;
}
