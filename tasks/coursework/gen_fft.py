#!/usr/bin/env python3

import argparse
from typing import TextIO

import numpy as np


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('fft_bins', type=int, help="FFT bin number")
    parser.add_argument('input_file', type=argparse.FileType('r'), help="Input file")
    parser.add_argument('output_file', type=argparse.FileType('w'), help="Output file")
    args = parser.parse_args()

    fft_bins: int = args.fft_bins
    input_file: TextIO = args.input_file
    output_file: TextIO = args.output_file

    raw = np.array([int(x, 16) for x in input_file], dtype=np.int32)
    raw = np.where(((raw & (1 << 23)) != 0), raw - (1 << 24), raw)
    signal = raw.astype(np.float64) / ((1 << 23) - 1)

    start = 0
    while start + fft_bins <= len(signal):
        x = signal[start:start + fft_bins]
        start = start + fft_bins
        spectrum = np.fft.fft(x)
        amp = np.abs(spectrum[1:fft_bins // 2] / (fft_bins // 2))
        output = np.clip(np.round((amp ** 2) * ((1 << 32) - 1)), 0, ((1 << 31) - 1)).astype(np.uint32)
        for n in output:
            output_file.write(f"{n:08X}\n")

    output_file.close()


if __name__ == "__main__":
    main()
