#!/bin/bash

xrandr --setprovideroutputsource modesetting NVIDIA-0
xrandr --auto

~/.screenlayout/default.sh
xset +fp /home/soorya/.fonts
xset fp rehash

exec dbus-launch --exit-with-session i3
