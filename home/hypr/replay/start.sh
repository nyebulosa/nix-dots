#!/usr/bin/env bash

killall -SIGINT gpu-screen-recorder

notify-send "Recording re/started"

gpu-screen-recorder -w screen -f 60 -k hevc -a "default_output|default_input" -a default_output -a default_input -o ~/Videos/replay/ -r 90 -c mp4
