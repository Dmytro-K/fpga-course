#include <climits>
#include "moving_max.h"

#include <cstdio>

#define ALGORITHM_VERSION 3

/* Ковзний максимум: out_data[n] = найбільше з останніх WINDOW відліків,
   разом із поточним відліком n.
   Допишіть місця, позначені TODO. */
void moving_max(const int in_data[N_SAMPLES], int out_data[N_SAMPLES]) {
#pragma HLS PIPELINE II=1
    int window[WINDOW];      /* тут зберігаються останні WINDOW відліків */

INIT_LOOP:
    for (int k = 0; k < WINDOW; k++) {
        window[k] = INT_MIN;
    }

MAIN_LOOP:
    for (int n = 0; n < N_SAMPLES; n++) {
        /* TODO 2: зсуньте вміст window на одну позицію:
                   window[k] отримує значення window[k-1],
                   для k від WINDOW-1 до 1 (по спаданню) */
        for (int k = (WINDOW - 1); k > 0; --k) {
            window[k] = window[k - 1];
            // printf("window[%d]: %02x\n", k, window[k]);
        }

        /* TODO 3: покладіть новий відлік in_data[n] у window[0].
                   in_data[n] читається ТІЛЬКИ тут і ТІЛЬКИ один раз */
        window[0] = in_data[n];

        /* TODO 4: знайдіть найбільше значення серед усіх window[0..WINDOW-1]
                   і запишіть його в out_data[n] */

#if ALGORITHM_VERSION == 1
        int max = window[0];
        
        for (int i = 1; i < WINDOW; ++i) {
            if (window[i] > max) {
                max = window[i];
            }
        }
#endif

#if ALGORITHM_VERSION == 2
        int max_0 = MAX(window[0], window[1]);
        int max_2 = MAX(window[2], window[3]);
        int max_4 = MAX(window[4], window[5]);
        int max_6 = MAX(window[6], window[7]);
        int max_0_2 = MAX(max_0, max_2);
        int max_4_6 = MAX(max_4, max_6);
        int max = MAX(max_0_2, max_4_6);
#endif

#if ALGORITHM_VERSION == 3
        int maxes[WINDOW];
        
        for (int i = 0; i < WINDOW; ++i) {
            maxes[i] = window[i];
        }

        int len = WINDOW;
LOG_LOOP:
        while (len > 1) {
            const int len_half = len / 2;
MAX_LOOP:
            for (int i = 0; i < len_half; ++i) {
                maxes[i] = MAX(maxes[i << 1], maxes[(i << 1) + 1]);
            }

            len = len_half;
        }

        int max = maxes[0];
#endif

        out_data[n] = max;

    }
}