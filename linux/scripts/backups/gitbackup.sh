#!/bin/bash
for dir in */; do
    cd "$dir"
    if [ -d .git ]; then
        git pull
        echo "Actualizado: $dir"
    fi
    cd ..
done
