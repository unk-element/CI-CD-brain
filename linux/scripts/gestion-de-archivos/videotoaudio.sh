#!/bin/bash
ffmpeg -i "$1" -vn -acodec libmp3lame -q:a 2 "${1%.*}.mp3"
