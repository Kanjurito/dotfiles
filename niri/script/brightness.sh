#!/bin/bash
BUSES=(0 1 3)
STEP=10
ACTION=$1 # "up" ou "down"

for BUS in "${BUSES[@]}"; do
    if [ "$ACTION" == "up" ]; then
        ddcutil setvcp 10 + $STEP --bus $BUS &
    else
        ddcutil setvcp 10 - $STEP --bus $BUS &
    fi
done
wait
