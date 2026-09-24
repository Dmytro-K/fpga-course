#include <stdbool.h>

#include <xparameters.h>
#include <xil_io.h>
#include <xgpio.h>
#include <xtmrctr.h>

#define LED_BASEADDR XPAR_AXI_GPIO_0_BASEADDR
#define BTN_BASEADDR XPAR_AXI_GPIO_1_BASEADDR
#define TMR_BASEADDR XPAR_AXI_TIMER_0_BASEADDR
#define LED_COUNT XPAR_AXI_GPIO_0_GPIO_WIDTH

#define TIMER_MIN 100
#define TIMER_MAX 10000
#define TIMER_DEFAULT 1000
#define TIMER_STEP 100

#define BTN_REVERSE 0
#define BTN_SPEED_UP 1
#define BTN_SPEED_DOWN 2
#define BTN_PAUSE 3

#define DEBOUNCE_TIME 10

#define BIT(n) (1 << (n))

XGpio led_gpio, btn_gpio;
XTmrCtr timer;

int main() {
    XGpio_Config *cfg_ptr;

    cfg_ptr = XGpio_LookupConfig(LED_BASEADDR);
    XGpio_CfgInitialize(&led_gpio, cfg_ptr, cfg_ptr->BaseAddress);

    cfg_ptr = XGpio_LookupConfig(BTN_BASEADDR);
    XGpio_CfgInitialize(&btn_gpio, cfg_ptr, cfg_ptr->BaseAddress);

    XGpio_SetDataDirection(&led_gpio, 1, 0x0);
    XGpio_SetDataDirection(&btn_gpio, 1, 0xF);

    XTmrCtr_Initialize(&timer, TMR_BASEADDR);
    XTmrCtr_SetOptions(&timer, 0, XTC_AUTO_RELOAD_OPTION);
    XTmrCtr_SetResetValue(&timer, 0, 0);
    XTmrCtr_Start(&timer, 0);

    s32 now = (s32)XTmrCtr_GetValue(&timer, 0);
    s32 next_tick = now;

    u32 led_i = 0;
    s32 direction = 1;
    s32 timer_delay = TIMER_DEFAULT;
    bool enable = true;
    u32 btn_value_prev = 0;
    s32 debounce_timeout;
    bool digit_changed = false;

    while (1) {
        now = (s32)XTmrCtr_GetValue(&timer, 0);
        if (enable == true)
        {
            if ((now - next_tick) >= 0)
            {
                next_tick = now + timer_delay;

                XGpio_DiscreteWrite(&led_gpio, 1, BIT(led_i));
                led_i = (led_i + direction) % LED_COUNT;
            }
        }

        u32 btn_value = XGpio_DiscreteRead(&btn_gpio, 1);
        if (btn_value != btn_value_prev)
        {
            btn_value_prev = btn_value;
            debounce_timeout = now + DEBOUNCE_TIME;
            digit_changed = true;
        }
        else if ((digit_changed == true) && ((now - debounce_timeout) >= 0))
        {
            digit_changed = false;

            if ((btn_value & BIT(BTN_REVERSE)) != 0)
            {
                if (direction > 0)
                {
                    direction = -1;
                }
                else
                {
                    direction = 1;
                }
            }
            else if ((btn_value & BIT(BTN_SPEED_UP)) != 0)
            {
                timer_delay -= TIMER_STEP;
                if (timer_delay < TIMER_MIN)
                {
                    timer_delay = TIMER_MIN;
                }
            }
            else if ((btn_value & BIT(BTN_SPEED_DOWN)) != 0)
            {
                timer_delay += TIMER_STEP;
                if (timer_delay > TIMER_MAX)
                {
                    timer_delay = TIMER_MAX;
                }
            }
            else if ((btn_value & BIT(BTN_PAUSE)) != 0)
            {
                enable = !enable;
                next_tick = now;
            }
        }
    }

    return 0;
}