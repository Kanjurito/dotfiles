#!/bin/bash
ddcutil getvcp 10 --bus 3 | grep -oP 'current value =\s*\K[0-9]+'
