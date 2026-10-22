#include <string.h>

#include "xparameters.h"
#include "xil_io.h"
#include "xil_printf.h"
// #include <xparameters_ps.h>

// #define BASE    XPAR_TOP_0_BASEADDR
// #define STATUS  0x00
// #define DATA    0x04

typedef struct {
    volatile uint32_t ISR;
    volatile uint32_t IER;
    volatile uint32_t TDFR;
    volatile uint32_t TDFV;
    volatile uint32_t TDFD;
    volatile uint32_t TLR;
    volatile uint32_t RDFR;
    volatile uint32_t RDFO;
    volatile uint32_t RDFD;
    volatile uint32_t RLR;
    volatile uint32_t SRR;
} axis_fifo_t;

#define ISR_RC (1u << 26)
#define ISR_ERR (0xFu << 28)

typedef struct 
{
    volatile const uint32_t status;
    volatile const uint32_t data;
} i2s_input_t;

// #define TOP ((top_t *)XPAR_TOP_0_BASEADDR)
#define LED ((volatile uint32_t *)XPAR_LED_0_BASEADDR)
#define I2S ((i2s_input_t *)XPAR_I2S_INPUT_0_BASEADDR)

#define LED_N 5

#define FIFO  ((axis_fifo_t *)XPAR_AXI_FIFO_MM_S_0_BASEADDR)

#define CHECK_FLAG(value, mask) (((value) & (mask)) == (mask))

#define FFT_SIZE 128

// #define BAND_SIZE (FFT_SIZE / LED_N)

#define PWM_VALUE_MAX 1023

typedef struct __attribute__((packed))
{
    uint16_t re;
    uint16_t im;
} cvalue_t;

int main(void)
{
    // xil_printf("start\r\n");
    // while (1) {
    //     if (CHECK_FLAG(TOP->status, 1)) {
    //         uint32_t num = TOP->data;
    //         // outbyte(c);
    //         xil_printf("num: %u\r\n", (unsigned)num);
    //     }
    // }

    // static uint16_t buf[FFT_SIZE];
    static uint32_t fftbuf[FFT_SIZE];
    // size_t len = 0;
    
    FIFO->TDFR = 0xA5;
    FIFO->RDFR = 0xA5;
    FIFO->ISR  = 0xFFFFFFFF;

    while (1)
    {
START: 
    
        memset(fftbuf, 0, sizeof(fftbuf));
    
        for (size_t i = 0; i < FFT_SIZE; ++i)
        {
            while (CHECK_FLAG(I2S->status, 1) == 0)
            {
            }
            
            fftbuf[i] = (I2S->data & ((1 << 24) - 1)) >> 8;
        }

        for (size_t i = 0; i < FFT_SIZE; ++i)
        {
            FIFO->TDFD =  fftbuf[i];
        }
        
        FIFO->TLR = FFT_SIZE * sizeof(uint32_t);

        while (!(FIFO->ISR & ISR_RC))
        {
            if (FIFO->ISR & ISR_ERR)
            {
                FIFO->ISR = ISR_ERR;
                goto START;
            }
        }

        FIFO->ISR = ISR_RC;

        uint32_t len = FIFO->RLR / sizeof(uint32_t);
        uint32_t half = len / 2;
        uint64_t sum[LED_N] = {0};

        uint32_t band_size = (half - 1) / LED_N;

        for (uint32_t i = 0; i < len; ++i)
        {
            uint32_t data = FIFO->RDFD;

            if (i == 0 || i >= half)
            {
                // Remove DC and mirror half
                continue;
            }

            int32_t re = (int16_t)(data & 0xFFFF);
            int32_t im = (int16_t)((data >> 16) & 0xFFFF);

            uint32_t band = (i - 1) * LED_N / (half - 1);
            sum[band] += (uint32_t)(re * re) + (uint32_t)(im * im);
        }

        for (uint32_t b = 0; b < LED_N; ++b)
        {
            uint32_t led_value = sum[b] * (PWM_VALUE_MAX + 1) / band_size / (1 << 15);

            if (led_value > PWM_VALUE_MAX)
            {
                led_value = PWM_VALUE_MAX;
            }

            LED[b] = led_value;
        }
    }
}
