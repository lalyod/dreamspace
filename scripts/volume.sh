#!/bin/bash

# Change volume
case $1 in
  up)
    pactl set-sink-volume @DEFAULT_SINK@ +5%
    ;;
  down)
    pactl set-sink-volume @DEFAULT_SINK@ -5%
    ;;
  mute)
    pactl set-sink-mute @DEFAULT_SINK@ toggle
    ;;
esac

# Get volume
volume=$(pactl get-sink-volume @DEFAULT_SINK@ | awk '{print $5}' | head -n1 | tr -d '%')

# Check mute state
mute=$(pactl get-sink-mute @DEFAULT_SINK@ | awk '{print $2}')

if [ "$mute" = "yes" ]; then
  dunstify -r 9993 -u low "🔇 Muted" -h int:value:0
else
  dunstify -r 9993 -u low "🔊 Volume: ${volume}%" -h int:value:$volume
fi
