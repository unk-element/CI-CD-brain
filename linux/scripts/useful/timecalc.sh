#!/bin/bash
start=$(date +%s)
read -p "Presiona Enter cuando termines..."
end=$(date +%s)
echo "Tiempo transcurrido: $((end-start)) segundos"
