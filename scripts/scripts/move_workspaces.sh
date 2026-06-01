DISPLAY=$(xrandr | grep -P '(?<!eDP-1) connected ' | awk '{print $1}')
# swap below to move all to laptop screen:
# DISPLAY=eDP-1
json=$(i3-msg -t get_workspaces | jq -c '.[]')
nums=$(echo $json | jq 'select(.num != 7) | .num')
focused_name=$(echo $json | jq 'select(.focused == true) | .name')
for num in $nums; do
  name=$(echo $json | jq "select(.num == $num) | .name")
  i3-msg workspace $name
  i3-msg move workspace to output $DISPLAY
done
# return focus:
i3-msg workspace $focused_name
