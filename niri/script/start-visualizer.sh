#!/bin/bash

# Wait until PulseAudio/PipeWire is active before starting
until pactl info &>/dev/null; do
    sleep 0.5
done

# Clean up and recreate the named pipe (FIFO) for CAVA data
rm -f /tmp/cava.fifo
mkfifo /tmp/cava.fifo

# Launch CAVA in the background
cava &

# Wait until the FIFO exists and starts receiving data
until [ -p /tmp/cava.fifo ] && timeout 1 cat /tmp/cava.fifo | read -r; do
    sleep 0.3
done

# Execute Quickshell to render the visualizer using the prepared data
exec qs -p ~/.config/quickshell/AudioVisualizer
