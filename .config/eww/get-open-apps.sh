#!/bin/bash

CLIENTS=$(hyprctl clients -j 2>/dev/null)
if [ -z "$CLIENTS" ] || [ "$CLIENTS" = "null" ]; then
    echo "[]"
    exit
fi

echo "$CLIENTS" | jq '
    [.[] | .class] | unique | map(
        . as $class | 
        if $class == "firefox" then
            {"name": "Firefox", "cmd": "firefox", "icon": "/home/lyod/.local/share/icons/WhiteSur/apps/scalable/firefox.svg", "class": $class}
        elif $class == "com.mitchellh.ghostty" then
            {"name": "Terminal", "cmd": "ghostty", "icon": "/home/lyod/.local/share/icons/WhiteSur/apps/scalable/terminal.svg", "class": $class}
        elif $class == "org.kde.dolphin" then
            {"name": "Files", "cmd": "nautilus", "icon": "/home/lyod/.local/share/icons/WhiteSur/apps/scalable/nautilus.svg", "class": $class}
        elif $class == "code" then
            {"name": "Code", "cmd": "code", "icon": "/home/lyod/.local/share/icons/WhiteSur/apps/scalable/code.svg", "class": $class}
        elif $class == "gnome-control-center" then
            {"name": "Settings", "cmd": "gnome-control-center", "icon": "/home/lyod/.local/share/icons/WhiteSur/apps/scalable/preferences-system.svg", "class": $class}
        elif $class == "discord" then
            {"name": "Discord", "cmd": "discord", "icon": "/home/lyod/.local/share/icons/WhiteSur/apps/scalable/discord.svg", "class": $class}
        elif $class == "google-chrome" then
            {"name": "Chrome", "cmd": "google-chrome", "icon": "/home/lyod/.local/share/icons/WhiteSur/apps/scalable/google-chrome.svg", "class": $class}
        elif $class == "steam" then
            {"name": "Steam", "cmd": "steam", "icon": "/home/lyod/.local/share/icons/WhiteSur/apps/scalable/steam.svg", "class": $class}
        elif $class == "spotify" then
            {"name": "Spotify", "cmd": "spotify", "icon": "/home/lyod/.local/share/icons/WhiteSur/apps/scalable/spotify.svg", "class": $class}
        else
            {"name": $class, "cmd": $class, "icon": "/home/lyod/.local/share/icons/WhiteSur/apps/scalable/applications-other.svg", "class": $class}
        end
    ) | tojson
' 2>/dev/null
