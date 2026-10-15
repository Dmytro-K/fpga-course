#include <cstdio>

#include "moving_max.h"

static const int data[N_SAMPLES] =
{
  0xb3, 0x42, 0x36, 0xa5, 0x73, 0xed, 0xa9, 0xbc, 0x1a, 0x64, 0xe6, 0x26,
  0x0e, 0xd4, 0xbb, 0x84, 0x4f, 0xd5, 0x40, 0xe6, 0x54, 0xc1, 0x38, 0xe6,
  0x7b, 0xd6, 0xe2, 0x6a, 0x23, 0x4b, 0xb7, 0xff, 0xfc, 0x30, 0x40, 0xe4,
  0x8a, 0xfb, 0x7f, 0xce, 0x93, 0x89, 0x85, 0x8d, 0xd1, 0x15, 0x64, 0xa0,
  0x1c, 0x4c, 0xf0, 0xba, 0xed, 0xa8, 0x32, 0xe2, 0x33, 0x5c, 0x69, 0xbe,
  0x7f, 0xdc, 0x85, 0xa4
};

static int max(const int in[], int size)
{
    int mx = in[0];
    for (int i = 1; i < size; ++i) {
        if (in[i] > mx) {
            mx = in[i];
        }
    }

    return mx;
}

static void reference(const int in[N_SAMPLES], int out[N_SAMPLES])
{
    for (int i = 0; i < N_SAMPLES; ++i) {
        int start = MAX(0, i - WINDOW + 1);
        int end = i;
        
        out[i] = max(&in[start], end - start + 1);
    }
}

int main()
{
    int result[N_SAMPLES];
    int golden[N_SAMPLES];

    int errors = 0;

    /* Три виклики поспіль -- щоб co-simulation могла виміряти II між транзакціями */
    for (int t = 0; t < 3; t++) {
        reference(data, golden);
        moving_max(data, result);

        for (int i = 0; i < N_SAMPLES; ++i) {
            if (result[i] != golden[i]) {
                printf("MISMATCH: %d %02x != %02x\n", i, result[i], golden[i]);
                errors++;
            }
        }
    }

    if (errors == 0) {
        printf("Test success!\n");
        return 0;
    } else {
        printf("Test fail!\n");
        return 1;
    }
}