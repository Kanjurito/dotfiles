#!/bin/bash
LOCK="/tmp/qs-media.lock"
exec 9>"$LOCK"
flock -n 9 || exit 0

if qs ipc -p ~/.config/quickshell/media-player call toggle onMessage 2>/dev/null; then
    exit 0
fi

nohup qs -p ~/.config/quickshell/media-player > /tmp/qs-media.log 2>&1 &
disown

for i in $(seq 1 10); do
    sleep 0.3
    if qs ipc -p ~/.config/quickshell/media-player call toggle onMessage 2>/dev/null; then
        exit 0
    fi
done
