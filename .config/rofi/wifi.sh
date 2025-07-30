#!/usr/bin/env bash

# Get list of available Wi-Fi networks using iwctl
networks=$(iwctl station wlan0 get-networks | awk 'NR>4 {print $1}' | sort -u)

# Show networks in rofi menu
chosen_ssid=$(printf '%s\n' "$networks" | rofi -dmenu -p "Wi-Fi SSID")

# Exit if nothing chosen
[[ -z "$chosen_ssid" ]] && exit 1

# Ask for passphrase
passphrase=$(rofi -dmenu -p "Password for $chosen_ssid" -password)

# Connect using iwctl
# Use expect to handle passphrase input
expect <<EOF
spawn iwctl --passphrase="$passphrase" station wlan0 connect "$chosen_ssid"
expect eof
EOF

# Notify user
if iwctl station wlan0 show | grep -q "Connected network.*$chosen_ssid"; then
    notify-send "Wi-Fi" "Connected to $chosen_ssid"
else
    notify-send "Wi-Fi" "Failed to connect to $chosen_ssid"
fi

