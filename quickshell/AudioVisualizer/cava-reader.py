#!/usr/bin/env python3
import sys
import os

# --- CONFIGURATION ---
# Use the first argument as FIFO path, or default to /tmp/cava.fifo
fifo = sys.argv[1] if len(sys.argv) > 1 else "/tmp/cava.fifo"
# Use the second argument for number of bars, or default to 48
bars = int(sys.argv[2]) if len(sys.argv) > 2 else 48

while True:
    try:
        # Open the CAVA output pipe in binary read mode
        with open(fifo, "rb") as f:
            while True:
                # Read a chunk of data matching the number of bars
                data = f.read(bars)
                if not data:
                    # Pipe was closed, exit the inner loop to reconnect
                    break
                
                # Convert binary bytes to a space-separated string of integers
                # and flush stdout immediately for Quickshell to read
                print(" ".join(str(b) for b in data), flush=True)
                
    except Exception:
        # If the FIFO isn't ready or an error occurs, wait and retry
        import time
        time.sleep(0.5)