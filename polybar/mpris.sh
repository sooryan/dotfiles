#!/bin/bash

# Specifying the icon(s) in the script
# This allows us to change its appearance conditionally
icon=""

player_status=$(timeout 1 playerctl status 2> /dev/null)
if [[ $? -eq 0 ]]; then
    metadata="$(playerctl metadata artist) - $(playerctl metadata title)"
fi

mpc_status=$(mpc -p 7000 | sed -n 2p | cut -d ' ' -f1)
mpc_metadata="$(mpc -p 7000 -f ' %artist% - %title%' current)"

# Foreground color formatting tags are optional
if [[ $player_status = "Playing" ]]; then
    echo "$icon $metadata"       # Orange when playing
elif [[ $mpc_status = "[playing]" ]]; then
	echo "$icon $mpc_metadata"       # Orange when playing
elif [[ $player_status = "Paused" ]]; then
    echo "%{F#65737E}$icon $metadata"       # Greyed out info when paused
elif [[ $mpc_status = "[paused]" ]]; then
	echo "%{F#65737E}$icon $mpc_metadata"       # Greyed out info when paused
else
    echo ""                 # Greyed out icon when stopped
fi
