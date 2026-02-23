#!/bin/bash
LOCK="/tmp/qs-usermenu.lock"
exec 9>"$LOCK"
flock -n 9 || exit 0

if qs ipc -p ~/.config/quickshell/user-menu call toggle onMessage 2>/dev/null; then
    exit 0
fi

nohup qs -p ~/.config/quickshell/user-menu > /tmp/qs-usermenu.log 2>&1 &
disown

for i in $(seq 1 15); do
    sleep 0.3
    if qs ipc -p ~/.config/quickshell/user-menu call toggle onMessage 2>/dev/null; then
        exit 0
    fi
done
