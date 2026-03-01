#!/bin/bash
iface=$(ip route get 1.1.1.1 2>/dev/null | awk 'NR==1{for(i=1;i<=NF;i++) if($i=="dev") {print $(i+1); exit}}')
[ -z "$iface" ] && exit 1
r1=$(cat /sys/class/net/$iface/statistics/rx_bytes)
t1=$(cat /sys/class/net/$iface/statistics/tx_bytes)
sleep 1
r2=$(cat /sys/class/net/$iface/statistics/rx_bytes)
t2=$(cat /sys/class/net/$iface/statistics/tx_bytes)
echo "$(( (r2-r1)/1024 ))|$(( (t2-t1)/1024 ))"
