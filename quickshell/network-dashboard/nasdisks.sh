#!/bin/bash
ssh -o ConnectTimeout=3 -o StrictHostKeyChecking=no root@192.168.1.27 \
    'df -h /dev/sda1 /dev/sdb1 2>/dev/null | awk "NR>1 {print \$3\"|\"\$2\"|\"\$5}"' 2>/dev/null \
    || echo "unreachable"
