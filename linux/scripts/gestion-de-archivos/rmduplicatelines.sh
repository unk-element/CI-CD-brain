#!/bin/bash
awk '!seen[$0]++' "$1" > temp && mv temp "$1"
