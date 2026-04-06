#!/bin/bash
APP="$1"
CLASS="$2"

# Handle dolphin alias - use full class name for focusing
if [ "$CLASS" = "org.kde.dolphin" ]; then
    EXISTS=$(hyprctl clients -j 2>/dev/null | jq -r '[.[] | .class] | map(. == "dolphin" or . == "org.kde.dolphin") | any' 2>/dev/null)
    if [ "$EXISTS" = "true" ]; then
        /usr/bin/hyprctl dispatch focuswindow "class:org.kde.dolphin"
    else
        /usr/bin/hyprctl dispatch exec "$APP"
    fi
else
    EXISTS=$(hyprctl clients -j 2>/dev/null | jq -r --arg cls "$CLASS" '[.[] | .class] | map(. == $cls) | any' 2>/dev/null)
    if [ "$EXISTS" = "true" ]; then
        /usr/bin/hyprctl dispatch focuswindow "class:$CLASS"
    else
        /usr/bin/hyprctl dispatch exec "$APP"
    fi
fi
