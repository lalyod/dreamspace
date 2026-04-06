#!/bin/bash
# Add or remove app from favorites

ACTION="$1"
APP="$2"

FAVORITES_FILE="/home/lyod/.config/eww/favorites.txt"

if [ ! -f "$FAVORITES_FILE" ]; then
    echo "firefox,com.mitchellh.ghostty,org.kde.dolphin,code,gnome-control-center" > "$FAVORITES_FILE"
fi

read -r FAVORITES < "$FAVORITES_FILE"

if [ "$ACTION" = "add" ]; then
    # Add if not already in favorites
    if ! echo "$FAVORITES" | grep -q "$APP"; then
        FAVORITES="$FAVORITES,$APP"
    fi
elif [ "$ACTION" = "remove" ]; then
    # Remove from favorites
    FAVORITES=$(echo "$FAVORITES" | tr ',' '\n' | grep -v "^$APP$" | tr '\n' ',' | sed 's/,$//')
fi

echo "$FAVORITES" > "$FAVORITES_FILE"
