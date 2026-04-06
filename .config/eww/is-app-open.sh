#!/bin/bash
hyprctl clients -j | jq -r '.[] | .class' | while read -r class; do
  case "$class" in
    firefox) echo "firefox:1" ;;
    com.mitchellh.ghostty) echo "ghostty:1" ;;
    org.kde.dolphin) echo "files:1" ;;
    code) echo "code:1" ;;
    gnome-control-center) echo "settings:1" ;;
    discord) echo "discord:1" ;;
    google-chrome) echo "chrome:1" ;;
    steam) echo "steam:1" ;;
    spotify) echo "spotify:1" ;;
  esac
done | grep "^$1:" > /dev/null && echo "1" || echo "0"
