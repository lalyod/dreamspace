#!/bin/bash

# Get connected monitors
CONNECTED_MONITORS=$(hyprctl monitors | grep "Monitor" | awk '{print $2}')

# Define your internal and external monitor names (adjust as needed, use `hyprctl monitors` to find yours)
INTERNAL_MONITOR="eDP-1" 
EXTERNAL_MONITOR="HDMI-A-1"

# Check if external monitor is connected
if echo "$CONNECTED_MONITORS" | grep "$EXTERNAL_MONITOR"; then
    # External connected: disable internal
    hyprctl keyword monitor "$INTERNAL_MONITOR",disable
	hyprctl keyword monitor "$EXTERNAL_MONITOR",1920x1080,144
fi
