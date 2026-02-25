#!/bin/bash
# Toggle waifu widget on all screens
LOCK="/tmp/qs-waifu.lock"
exec 9>"$LOCK"
flock -n 9 || exit 0

if qs ipc -p ~/.config/quickshell/waifu-widget call "waifu-DP-1" onMessage 2>/dev/null; then
    qs ipc -p ~/.config/quickshell/waifu-widget call "waifu-DP-2" onMessage 2>/dev/null || true
    qs ipc -p ~/.config/quickshell/waifu-widget call "waifu-HDMI-A-1" onMessage 2>/dev/null || true
    exit 0
fi

nohup qs -p ~/.config/quickshell/waifu-widget > /tmp/qs-waifu.log 2>&1 &
disown

for i in $(seq 1 15); do
    sleep 0.3
    if qs ipc -p ~/.config/quickshell/waifu-widget call "waifu-DP-1" onMessage 2>/dev/null; then
        qs ipc -p ~/.config/quickshell/waifu-widget call "waifu-DP-2" onMessage 2>/dev/null || true
        qs ipc -p ~/.config/quickshell/waifu-widget call "waifu-HDMI-A-1" onMessage 2>/dev/null || true
        exit 0
    fi
done
