#!/bin/bash
# Auto-find icon for a given window class

CLASS="$1"

# Function to normalize app names (lowercase + replace spaces with underscores)
normalize_name() {
    echo "$1" | tr '[:upper:]' '[:lower:]' | tr ' ' '_'
}

find_icon_for_class() {
    local class="$1"
    local normalized_class=$(normalize_name "$class")
    
    # Search in local and system .desktop files
    local desktop_file=""
    
     # Try to find .desktop file based on normalized class name (try both underscore and hyphen variants)
     for dir in "$HOME/.local/share/applications" "/usr/share/applications"; do
         # Try both underscore and hyphenated versions
         for class_variant in "$normalized_class" "${normalized_class//_/-}"; do
             if [ -f "$dir/${class_variant}.desktop" ]; then
                 desktop_file="$dir/${class_variant}.desktop"
                 break 2
             fi
             
             # Try case-insensitive search with this variant
             desktop_file=$(find "$dir" -maxdepth 1 -iname "${class_variant}*.desktop" 2>/dev/null | head -1)
             if [ -n "$desktop_file" ]; then
                 break 2
             fi
         done
     done
    
     # If found, extract icon name and normalize it
     if [ -n "$desktop_file" ]; then
         local icon_name=$(grep -i "^Icon=" "$desktop_file" 2>/dev/null | head -1 | cut -d'=' -f2 | tr -d ' ')
         local normalized_icon=$(normalize_name "$icon_name")
        
         if [ -n "$normalized_icon" ]; then
             # Try to resolve the icon
             local icon_path=""
             
             # Try both normalized (with underscores) and hyphenated variants
             for icon_variant in "$normalized_icon" "${normalized_icon//_/-}"; do
                 # Check in local icons
                 if [ -f "$HOME/.local/share/icons/$icon_variant" ]; then
                     echo "$HOME/.local/share/icons/$icon_variant"
                     return 0
                 fi
                 if [ -f "$HOME/.local/share/icons/$icon_variant.png" ]; then
                     echo "$HOME/.local/share/icons/$icon_variant.png"
                     return 0
                 fi
                 if [ -f "$HOME/.local/share/icons/$icon_variant.svg" ]; then
                     echo "$HOME/.local/share/icons/$icon_variant.svg"
                     return 0
                 fi
                 
                 # Check in common icon paths
                 for icon_dir in "$HOME/.local/share/icons" "/usr/share/icons" "/usr/share/pixmaps"; do
                     for ext in "" ".png" ".svg" ".xpm"; do
                         if [ -f "$icon_dir/$icon_variant$ext" ]; then
                             echo "$icon_dir/$icon_variant$ext"
                             return 0
                         fi
                         
                         # Check subdirectories
                         if [ -d "$icon_dir/hicolor" ]; then
                             for size in 48x48 32x32 24x24 16x16 scalable apps; do
                                 if [ -f "$icon_dir/hicolor/$size/apps/$icon_variant$ext" ]; then
                                     echo "$icon_dir/hicolor/$size/apps/$icon_variant$ext"
                                     return 0
                                 fi
                             done
                         fi
                         
                         if [ -d "$icon_dir/WhiteSur" ]; then
                             for path in "WhiteSur/apps/scalable/$icon_variant.svg" "WhiteSur-dark/apps/scalable/$icon_variant.svg"; do
                                 if [ -f "$HOME/.local/share/icons/$path" ]; then
                                     echo "$HOME/.local/share/icons/$path"
                                     return 0
                                 fi
                             done
                         fi
                     done
                 done
             done
             
             # Return the icon name if we found it but not the file
             if [ -n "$normalized_icon" ]; then
                 echo "$normalized_icon"
                 return 0
             fi
        fi
    fi
    
    # Return empty if not found
    echo ""
}

result=$(find_icon_for_class "$CLASS")
echo "$result"
