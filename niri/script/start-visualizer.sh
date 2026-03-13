#!/bin/bash
# Attend que pipewire soit prêt
until pactl info &>/dev/null; do
    sleep 0.5
done

# Prépare le FIFO
rm -f /tmp/cava.fifo
mkfifo /tmp/cava.fifo

# Lance cava et attend qu'il écrive dans le FIFO
cava &
until [ -p /tmp/cava.fifo ] && timeout 1 cat /tmp/cava.fifo | read -r; do
    sleep 0.3
done

# Lance quickshell
exec qs -p /home/alterra/dotfiles/quickshell/AudioVisualizer
