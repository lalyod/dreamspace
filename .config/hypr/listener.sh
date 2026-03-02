SOCKET="$XDG_RUNTIME_DIR/hypr/$HYPRLAND_INSTANCE_SIGNATURE/.socket2.sock"

socat -u UNIX-CONNECT:"$SOCKET" - | while read -r line; do
	case "$line" in
		activewindow*|activewindow2*)
			pkill -RTMIN+10 waybar
			;;
	esac
done
