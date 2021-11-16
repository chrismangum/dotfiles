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

if [[ $hostname == 'archtop' ]]; then
  display2=$(xrandr | grep ' connected ' | tail -n 1 | cut -d ' ' -f 1)
  if [[ $display2 == 'DP1' ]]; then
    xrandr --output eDP1 --mode 1920x1080 --right-of DP1 --output DP1 --mode 1920x1080 --rate 144
  elif [[ $display2 == 'HDMI1' ]]; then
    xrandr --output eDP1 --mode 1920x1080 --right-of HDMI1 --output HDMI1 --mode 1920x1080 --gamma 1.3:1.3:1.3
  fi
elif [[ $hostname == 'archbox' ]]; then
  xrandr --output DP-2 --mode 1920x1080 --rate 144 --gamma 1.4:1.4:1.4
elif [[ $hostname == 'archnuc' ]]; then
  xrandr --output HDMI1 --mode 1920x1080
fi

exec i3
