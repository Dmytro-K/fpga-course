#include "xparameters.h"
#include "xil_io.h"
#include "xaxidma.h"
#include <xgpio.h>

#define GPIO_BASEADDR XPAR_AXI_GPIO_BASEADDR

#if defined(XPAR_AXI_DMA_0_BASEADDR)
  #define DMA_BASEADDR XPAR_AXI_DMA_0_BASEADDR
#elif defined(XPAR_XAXIDMA_0_BASEADDR)
  #define DMA_BASEADDR XPAR_XAXIDMA_0_BASEADDR
#elif defined(XPAR_AXIDMA_0_BASEADDR)
  #define DMA_BASEADDR XPAR_AXIDMA_0_BASEADDR
#else
  #error "Не знайдено базову адресу DMA: у xparameters.h знайдіть BASEADDR для AXI_DMA і впишіть у DMA_BASEADDR"
#endif

#if defined(XPAR_AXI4_FULL_RAM_0_BASEADDR)
  #define RAM_BASE XPAR_AXI4_FULL_RAM_0_BASEADDR
#elif defined(XPAR_AXI4_FULL_RAM_0_S_AXI_BASEADDR)
  #define RAM_BASE XPAR_AXI4_FULL_RAM_0_S_AXI_BASEADDR
#elif defined(XPAR_AXI4_FULL_RAM_2_0_BASEADDR)
  #define RAM_BASE XPAR_AXI4_FULL_RAM_2_0_BASEADDR
#elif defined(XPAR_AXI4_FULL_RAM_2_0_S_AXI_BASEADDR)
  #define RAM_BASE XPAR_AXI4_FULL_RAM_2_0_S_AXI_BASEADDR
#else
  #error "Не знайдено базову адресу axi4_full_ram: у xparameters.h знайдіть BASEADDR цього блока і впишіть у RAM_BASE"
#endif

#define IMAGE_SIZE (320 * 200)

XAxiDma dma_inst;
XGpio gpio;
volatile int errors = -1;

int main(void)
{
    u32 btn_value;

    XGpio_Config *cfg_ptr;

    cfg_ptr = XGpio_LookupConfig(GPIO_BASEADDR);
    XGpio_CfgInitialize(&gpio, cfg_ptr, cfg_ptr->BaseAddress);

    XGpio_SetDataDirection(&gpio, 1, 0x1);
    XGpio_SetDataDirection(&gpio, 2, 0x0);

    /* 2. Налаштувати DMA (у SDT-режимі LookupConfig приймає базову адресу) */
    XAxiDma_Config *cfg = XAxiDma_LookupConfig(DMA_BASEADDR);
    if (cfg == NULL) { errors = -2; while (1) {} }
    XAxiDma_CfgInitialize(&dma_inst, cfg);
    if (XAxiDma_HasSg(&dma_inst)) { errors = -3; while (1) {} }

    while (1)
    {
        btn_value = XGpio_DiscreteRead(&gpio, 1);
        if (btn_value == 1)
        {
            // Wait for button release
            while (1 == XGpio_DiscreteRead(&gpio, 1));

            if (XAxiDma_SimpleTransfer(&dma_inst, RAM_BASE, IMAGE_SIZE, XAXIDMA_DEVICE_TO_DMA) != XST_SUCCESS) {
                errors = -4; while (1) {}
            }

            XGpio_DiscreteWrite(&gpio, 2, 1);

            // Delay
            for (volatile int i = 0; i < 10; ++i);

            XGpio_DiscreteWrite(&gpio, 2, 0);

            while (XAxiDma_Busy(&dma_inst, XAXIDMA_DEVICE_TO_DMA));
        }
    }
    
    return 0;
}