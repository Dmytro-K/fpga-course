#!/usr/bin/env python3

import argparse
from typing import TextIO

import numpy as np


def main():
    parser = argparse.ArgumentParser(description="Generate a combined signal of two sine waves.")
    parser.add_argument("--freq", type=int, default=16000, help="Discretization frequency (Hz)")
    parser.add_argument("--signals", type=float, nargs="+", required=True, help="Signals frequencies (Hz)")
    parser.add_argument("--amp", type=float, nargs="+", required=True, help="Signals magnitude")
    parser.add_argument("--time", type=float, required=True, help="Time (s)")
    parser.add_argument("FILE", type=argparse.FileType("w"), help="Output file")
    args = parser.parse_args()

    freq = args.freq
    signal_freqs = np.array(args.signals)
    signal_amps = np.array(args.amp)
    time: float = args.time
    file: TextIO = args.FILE

    t = np.arange(0, time, 1 / freq)
    signals = [np.sin(2 * np.pi * f * t) * a for f, a in zip(signal_freqs, signal_amps)]
    s = np.sum(signals, axis=0) / len(signals)
    result = (np.round( s* ((1 << 23) - 1))).astype(np.int32) & ((1 << 24) - 1)

    # text = "\n".join(f"{x:024b}" for x in result)
    text = "\n".join(f"{x:06x}" for x in result)

    file.write(text)
    file.write("\n")
    file.close()


if __name__ == "__main__":
    main()
