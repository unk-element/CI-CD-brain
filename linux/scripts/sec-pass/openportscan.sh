#!/bin/bash
HOST=${1:-localhost}
for port in {1..1000}; do
    timeout 1 bash -c "echo >/dev/tcp/$HOST/$port" 2>/dev/null && echo "Puerto $port abierto"
done
