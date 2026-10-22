#!/usr/bin/env python3
"""Reference LED values: repeats the processing done by main.c on MicroBlaze.

For every full FFT frame writes LED_N lines (hex), one per LED, in the same
units as the LED registers (0 .. PWM_VALUE_MAX).
"""

import argparse
from typing import TextIO

import numpy as np

PWM_VALUE_MAX = 1023
SCALE_DIV = 1 << 15


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('fft_size', type=int, help="FFT size")
    parser.add_argument('leds', type=int, default=5, help="LEDs count")
    parser.add_argument('input_file', type=argparse.FileType('r'), help="Input file")
    parser.add_argument('output_file', type=argparse.FileType('w'), help="Output file")
    args = parser.parse_args()

    fft_size: int = args.fft_size
    led_n: int = args.leds
    input_file: TextIO = args.input_file
    output_file: TextIO = args.output_file

    raw = np.array([int(x, 16) for x in input_file], dtype=np.int64)
    raw = np.where((raw & (1 << 23)) != 0, raw - (1 << 24), raw)

    hw = raw >> 8

    half = fft_size // 2
    bins_per_band = (half - 1) // led_n

    start = 0
    while start + fft_size <= len(hw):
        frame = hw[start:start + fft_size]
        start += fft_size

        spectrum = np.fft.fft(frame) / fft_size
        re = np.round(spectrum.real)
        im = np.round(spectrum.imag)
        power = re * re + im * im

        sums = np.zeros(led_n)
        for k in range(1, half):
            sums[(k - 1) * led_n // (half - 1)] += power[k]

        leds = sums // bins_per_band * (PWM_VALUE_MAX + 1) // SCALE_DIV
        leds = np.minimum(leds, PWM_VALUE_MAX).astype(int)

        for v in leds:
            output_file.write(f"{v:04X}\n")

    output_file.close()


if __name__ == "__main__":
    main()
