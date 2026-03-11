#!/bin/bash
LOCK="/tmp/qs-cc.lock"
exec 9>"$LOCK"
flock -n 9 || exit 0

if qs ipc -p ~/dotfiles/quickshell/control-center call toggle onMessage 2>/dev/null; then
    exit 0
fi

nohup qs -p ~/dotfiles/quickshell/control-center > /tmp/qs-cc.log 2>&1 &
disown

for i in $(seq 1 15); do
    sleep 0.3
    if qs ipc -p ~/dotfiles/quickshell/control-center call toggle onMessage 2>/dev/null; then
        exit 0
    fi
done
