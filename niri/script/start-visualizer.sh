#!/bin/bash
until pactl info &>/dev/null; do
    sleep 0.5
done

rm -f /tmp/cava.fifo
mkfifo /tmp/cava.fifo

cava &
until [ -p /tmp/cava.fifo ] && timeout 1 cat /tmp/cava.fifo | read -r; do
    sleep 0.3
done

exec qs -p /home/alterra/dotfiles/quickshell/AudioVisualizer
