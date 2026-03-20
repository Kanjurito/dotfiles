#!/bin/bash
# lock.sh — hyprlock

CONFIG="$HOME/dotfiles/swaylock/hyprlock.conf"

exec hyprlock --config "$CONFIG"
