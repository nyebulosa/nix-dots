#!/usr/bin/env bash

killall -SIGUSR1 gpu-screen-recorder

if [ $? -ne 0 ]; then
    notify-send "Error/Not recording"
    exit 1
fi
notify-send "Recording saved"
