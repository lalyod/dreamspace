#!/bin/bash

CLIENTS=$(hyprctl clients -j 2>/dev/null)
if [ -z "$CLIENTS" ] || [ "$CLIENTS" = "null" ]; then
    CLIENTS="[]"
fi

FAVORITES_FILE="/home/ucup/dotfiles/.config/eww/favorites.txt"
if [ -f "$FAVORITES_FILE" ]; then
    FAVORITES=$(cat "$FAVORITES_FILE")
else
    FAVORITES="firefox,com.mitchellh.ghostty,org.kde.dolphin,code,gnome-control-center"
    echo "$FAVORITES" > "$FAVORITES_FILE"
fi

declare -A APP_MAP=(
    ["firefox"]="Firefox|firefox|/home/ucup/.local/share/icons/WhiteSur/apps/scalable/firefox.svg"
    ["dolphin"]="Files|dolphin|/home/ucup/.local/share/icons/WhiteSur/apps/scalable/nautilus.svg"
    ["org.kde.dolphin"]="Files|dolphin|/home/ucup/.local/share/icons/WhiteSur/apps/scalable/nautilus.svg"
    ["code"]="Code|code|/home/ucup/.local/share/icons/WhiteSur/apps/scalable/code.svg"
    ["gnome-control-center"]="Settings|gnome-control-center|/home/ucup/.local/share/icons/WhiteSur/apps/scalable/preferences-system.svg"
    ["google-chrome"]="Chrome|google-chrome|/home/ucup/.local/share/icons/WhiteSur/apps/scalable/google-chrome.svg"
    ["discord"]="Discord|discord|/home/ucup/.local/share/icons/WhiteSur/apps/scalable/discord.svg"
    ["WebCord"]="WebCord|webcord|/home/ucup/.local/share/icons/WhiteSur/apps/scalable/discord.svg"
    ["steam"]="Steam|steam|/home/ucup/.local/share/icons/WhiteSur/apps/scalable/steam.svg"
    ["spotify"]="Spotify|spotify|/home/ucup/.local/share/icons/WhiteSur/apps/scalable/spotify.svg"
)

GENERIC_ICON="$HOME/.local/share/icons/WhiteSur/apps/scalable/applications-other.svg"
EWW_DIR="$HOME/dotfiles/.config/eww"

get_icon_for_class() {
    local class="$1"
    
    if [ -n "${APP_MAP[$class]}" ]; then
        echo "${APP_MAP[$class]}" | cut -d'|' -f3
        return
    fi
    
    local auto_icon=$(/home/ucup/.config/eww/find-icon.sh "$class" 2>/dev/null)
    
    if [ -n "$auto_icon" ] && [ -f "$auto_icon" ]; then
        echo "$auto_icon"
        return
    fi
    
    for theme in "WhiteSur" "WhiteSur-dark" "WhiteSur-light"; do
        for path in "$HOME/.local/share/icons/$theme/apps/scalable/$class.svg" \
                     "$HOME/.local/share/icons/$theme/apps/48x48/apps/$class.png"; do
            if [ -f "$path" ]; then
                echo "$path"
                return
            fi
        done
    done
    
    echo "$GENERIC_ICON"
}

get_name_for_class() {
    local class="$1"
    if [ -n "${APP_MAP[$class]}" ]; then
        echo "${APP_MAP[$class]}" | cut -d'|' -f1
    else
        local desktop_name=""
        for dir in "$HOME/.local/share/applications" "/usr/share/applications"; do
            desktop_name=$(grep -i "^Name=" "$dir/${class}.desktop" 2>/dev/null | head -1 | cut -d'=' -f2)
            [ -n "$desktop_name" ] && break
        done
        
        if [ -n "$desktop_name" ]; then
            echo "$desktop_name"
        else
            echo "$class"
        fi
    fi
}

get_cmd_for_class() {
    local class="$1"
    if [ -n "${APP_MAP[$class]}" ]; then
        echo "${APP_MAP[$class]}" | cut -d'|' -f2
    else
        echo "$class"
    fi
}

OPEN_APPS=$(echo "$CLIENTS" | jq -r '[.[] | .class] | unique | .[]' 2>/dev/null)

YUCK='(box :class "dock"'

IFS=',' read -ra FAV_ARRAY <<< "$FAVORITES"
for fav in "${FAV_ARRAY[@]}"; do
    [ -z "$fav" ] && continue
    
    if [ "$fav" = "org.kde.dolphin" ]; then
        is_open=$(echo "$CLIENTS" | jq -r '[.[] | .class] | map(. == "dolphin" or . == "org.kde.dolphin") | any' 2>/dev/null)
    else
        is_open=$(echo "$CLIENTS" | jq -r --arg cls "$fav" '[.[] | .class] | map(. == $cls) | any' 2>/dev/null)
    fi
    
    icon=$(get_icon_for_class "$fav")
    cmd=$(get_cmd_for_class "$fav")
    
    if [ "$is_open" = "true" ]; then
        YUCK="$YUCK (button :class \"icon\" :onclick \"/home/ucup/.config/eww/launch-or-focus.sh $cmd $fav\" :onrightclick \"$EWW_DIR/manage-favorites.sh remove $fav\" (box :orientation \"v\" :space-evenly false :valign \"center\" (image :path \"$icon\" :image-width 40 :image-height 40) (label :text \"●\" :class \"dot-active\")))"
    else
        YUCK="$YUCK (button :class \"icon\" :onclick \"/home/ucup/.config/eww/launch-or-focus.sh $cmd $fav\" :onrightclick \"$EWW_DIR/manage-favorites.sh remove $fav\" (box :orientation \"v\" :space-evenly false :valign \"center\" (image :path \"$icon\" :image-width 40 :image-height 40) (label :text \"●\" :class \"dot-inactive\")))"
    fi
done

while IFS= read -r open_app; do
     [ -z "$open_app" ] && continue
     
     is_favorite=false
     for fav in "${FAV_ARRAY[@]}"; do
         if [ "$fav" = "$open_app" ]; then
             is_favorite=true
             break
         fi
     done
    
    if [ "$open_app" = "dolphin" ] || [ "$open_app" = "org.kde.dolphin" ]; then
        for fav in "${FAV_ARRAY[@]}"; do
            if [ "$fav" = "org.kde.dolphin" ] || [ "$fav" = "dolphin" ]; then
                is_favorite=true
                break
            fi
        done
    fi
    
     if [ "$is_favorite" = "false" ]; then
         icon=$(get_icon_for_class "$open_app")
         cmd=$(get_cmd_for_class "$open_app")
         
         YUCK="$YUCK (button :class \"icon\" :onclick \"/home/ucup/.config/eww/launch-or-focus.sh $cmd $open_app\" :onrightclick \"/home/lyod/.config/eww/manage-favorites.sh add $open_app\" (box :orientation \"v\" :space-evenly false :valign \"center\" (image :path \"$icon\" :image-width 40 :image-height 40) (label :text \"●\" :class \"dot-active\")))"
     fi
 done <<< "$OPEN_APPS"

YUCK="$YUCK )"
echo "$YUCK"
