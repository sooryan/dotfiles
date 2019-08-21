#!/bin/bash

xrandr --setprovideroutputsource modesetting NVIDIA-0
xrandr --auto

xset +fp /home/soorya/.fonts
xset fp rehash

exec i3
