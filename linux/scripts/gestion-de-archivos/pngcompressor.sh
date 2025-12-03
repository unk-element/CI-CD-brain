#!/bin/bash
for img in *.png; do
    pngquant --quality=65-80 --ext .png --force "$img"
done
