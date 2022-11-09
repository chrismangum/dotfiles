#!/bin/bash

if [ -d /etc/X11/xinit/xinitrc.d ]; then
  for f in /etc/X11/xinit/xinitrc.d/*; do
    [ -x "$f" ] && . "$f"
  done
  unset f
fi

xrdb "${HOME}/.Xresources"
# synclient TouchpadOff=1
# redshift &
# xscreensaver -no-splash &
hostname=$(hostname)

if [[ $hostname == 'archx1g9' ]]; then
  display2=$(xrandr | grep ' connected ' | tail -n 1 | cut -d ' ' -f 1)
  xrandr --output eDP1 --mode 1920x1200 --right-of HDMI1 --output HDMI1 --mode 1920x1080 --gamma 1.3:1.3:1.3
  # xrandr --output eDP1 --mode 1920x1200
elif [[ $hostname == 'archbox' ]]; then
  xrandr --output DP-2 --mode 1920x1080 --rate 144 --gamma 1.4:1.4:1.4
elif [[ $hostname == 'archnuc' ]]; then
  xrandr --output HDMI1 --mode 1920x1080
fi

exec i3
