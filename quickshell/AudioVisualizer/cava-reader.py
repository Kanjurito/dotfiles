#!/usr/bin/env python3
import sys
import os

fifo = sys.argv[1] if len(sys.argv) > 1 else "/tmp/cava.fifo"
bars = int(sys.argv[2]) if len(sys.argv) > 2 else 48

while True:
    try:
        with open(fifo, "rb") as f:
            while True:
                data = f.read(bars)
                if not data:
                    break
                # Émet les valeurs séparées par des espaces + newline
                print(" ".join(str(b) for b in data), flush=True)
    except Exception:
        import time
        time.sleep(0.5)
