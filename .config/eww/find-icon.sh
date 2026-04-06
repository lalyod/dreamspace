#!/bin/bash
# Auto-find icon for a given window class

CLASS="$1"

find_icon_for_class() {
    local class="$1"
    
    # Search in local and system .desktop files
    local desktop_file=""
    
    # Try to find .desktop file based on class name
    for dir in "$HOME/.local/share/applications" "/usr/share/applications"; do
        if [ -f "$dir/${class}.desktop" ]; then
            desktop_file="$dir/${class}.desktop"
            break
        fi
        
        # Try case-insensitive search
        desktop_file=$(find "$dir" -maxdepth 1 -iname "${class}*.desktop" 2>/dev/null | head -1)
        if [ -n "$desktop_file" ]; then
            break
        fi
    done
    
    # If found, extract icon name
    if [ -n "$desktop_file" ]; then
        local icon_name=$(grep -i "^Icon=" "$desktop_file" 2>/dev/null | head -1 | cut -d'=' -f2 | tr -d ' ')
        
        if [ -n "$icon_name" ]; then
            # Try to resolve the icon
            local icon_path=""
            
            # Check in local icons
            if [ -f "$HOME/.local/share/icons/$icon_name" ]; then
                echo "$HOME/.local/share/icons/$icon_name"
                return 0
            fi
            if [ -f "$HOME/.local/share/icons/$icon_name.png" ]; then
                echo "$HOME/.local/share/icons/$icon_name.png"
                return 0
            fi
            if [ -f "$HOME/.local/share/icons/$icon_name.svg" ]; then
                echo "$HOME/.local/share/icons/$icon_name.svg"
                return 0
            fi
            
            # Check in common icon paths
            for icon_dir in "$HOME/.local/share/icons" "/usr/share/icons" "/usr/share/pixmaps"; do
                for ext in "" ".png" ".svg" ".xpm"; do
                    if [ -f "$icon_dir/$icon_name$ext" ]; then
                        echo "$icon_dir/$icon_name$ext"
                        return 0
                    fi
                    
                    # Check subdirectories
                    if [ -d "$icon_dir/hicolor" ]; then
                        for size in 48x48 32x32 24x24 16x16 scalable apps; do
                            if [ -f "$icon_dir/hicolor/$size/apps/$icon_name$ext" ]; then
                                echo "$icon_dir/hicolor/$size/apps/$icon_name$ext"
                                return 0
                            fi
                        done
                    fi
                    
                    if [ -d "$icon_dir/WhiteSur" ]; then
                        for path in "WhiteSur/apps/scalable/$icon_name.svg" "WhiteSur-dark/apps/scalable/$icon_name.svg"; do
                            if [ -f "$HOME/.local/share/icons/$path" ]; then
                                echo "$HOME/.local/share/icons/$path"
                                return 0
                            fi
                        done
                    fi
                done
            done
            
            # Return the icon name if we found it but not the file
            if [ -n "$icon_name" ]; then
                echo "$icon_name"
                return 0
            fi
        fi
    fi
    
    # Return empty if not found
    echo ""
}

result=$(find_icon_for_class "$CLASS")
echo "$result"
