#!/bin/bash
LOCK="/tmp/qs-network.lock"
exec 9>"$LOCK"
flock -n 9 || exit 0

if qs ipc -p ~/.config/quickshell/network-dashboard call toggle onMessage 2>/dev/null; then
    exit 0
fi

nohup qs -p ~/.config/quickshell/network-dashboard > /tmp/qs-network.log 2>&1 &
disown

for i in $(seq 1 15); do
    sleep 0.3
    if qs ipc -p ~/.config/quickshell/network-dashboard call toggle onMessage 2>/dev/null; then
        exit 0
    fi
done
