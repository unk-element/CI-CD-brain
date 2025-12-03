#!/bin/bash
while true; do
    clear
    echo "CPU: $(top -bn1 | grep "Cpu(s)" | awk '{print $2}')"
    echo "RAM: $(free -m | awk 'NR==2{printf "%.2f%%", $3*100/$2}')"
    sleep 5
done
