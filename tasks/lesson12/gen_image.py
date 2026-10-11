#!/usr/bin/env python3

with open("image.mem", "w") as f:
    for i in range(320*200):
        print(f"{i%256:02x}", file=f)
