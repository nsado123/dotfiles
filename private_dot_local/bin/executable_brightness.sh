#!/bin/bash

# Define the mapping between hyprctl names and ddcutil display numbers
declare -A monitor_map
monitor_map["DP-1"]=1
monitor_map["DP-2"]=2
# Add more mappings as needed

# Get the name of the focused monitor
focused_monitor=$(hyprctl monitors -j | jq -r '.[] | select(.focused) | .name')

# Get the corresponding ddcutil display number
display_number=${monitor_map[$focused_monitor]}

# Check if the focused monitor is in the map
if [ -n "$display_number" ]; then
    # Adjust brightness using ddcutil
    if [ "$1" == "+" ]; then
        ddcutil setvcp 10 + 10 --display "$display_number"  # Increase brightness by 10%
    elif [ "$1" == "-" ]; then
        ddcutil setvcp 10 - 10 --display "$display_number"  # Decrease brightness by 10%
    fi
else
    echo "Focused monitor '$focused_monitor' is not an external monitor or not mapped."
fi

