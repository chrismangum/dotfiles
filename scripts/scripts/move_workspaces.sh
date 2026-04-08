DISPLAY=$(xrandr | grep -P '(?<!eDP-1) connected ' | awk '{print $1}')
for ws in $(i3-msg -t get_workspaces | jq -r '.[].name'); do
    i3-msg workspace "$ws"
    if [[ "$ws" != "7" ]]; then
      i3-msg move workspace to output $DISPLAY
    fi
done
