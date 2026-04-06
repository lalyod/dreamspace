#!/bin/bash
HYPR_SOCKET="/run/user/1000/hypr/dd220efe7b1e292415bd0ea7161f63df9c95bfd3_1775228140_1239440472/.socket2.sock"

echo "$(hyprctl activewindow -j 2>/dev/null | jq -r '.class' 2>/dev/null)"
sync

exec socat - "$HYPR_SOCKET" 2>/dev/null | while IFS= read -r line; do
  if echo "$line" | grep -q "activewindow"; then
    class=$(echo "$line" | sed 's/.*>> //' | jq -r '.class' 2>/dev/null)
    echo "$class"
    sync
  fi
done
