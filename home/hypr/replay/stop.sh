#!/usr/bin/env bash


notify-send "Recording stopped"

killall -SIGINT gpu-screen-recorder
