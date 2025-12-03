#!/bin/bash
for video in *.avi; do
    ffmpeg -i "$video" "${video%.avi}.mp4"
done
