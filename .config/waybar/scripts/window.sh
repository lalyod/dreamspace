ACTIVE=$(hyprctl activewindow -j 2>/dev/null | jq -r .initialTitle)

echo "${ACTIVE}"
