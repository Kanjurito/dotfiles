#!/bin/bash

# Define the I2C buses for the monitors (usually 0, 1, 3 for multi-head setups)
BUSES=(0 1 3)
# Increment/decrement step percentage
STEP=10
# Get action from the first argument (up or down)
ACTION=$1

for BUS in "${BUSES[@]}"; do
    if [ "$ACTION" == "up" ]; then
        # Increase brightness (VCP code 10) on specific bus
        ddcutil setvcp 10 + $STEP --bus $BUS &
    else
        # Decrease brightness (VCP code 10) on specific bus
        ddcutil setvcp 10 - $STEP --bus $BUS &
    fi
done

# Wait for all background ddcutil processes to finish
wait
