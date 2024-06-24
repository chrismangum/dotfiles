#!/bin/bash

if [ -d /etc/X11/xinit/xinitrc.d ]; then
  for f in /etc/X11/xinit/xinitrc.d/*; do
    [ -x "$f" ] && . "$f"
  done
  unset f
fi

xrdb "${HOME}/.Xresources"
hostname=$(hostname)

if [[ $hostname == 'archx1g9' ]]; then
  xrandr --output eDP1 --mode 1920x1200 --right-of HDMI1 --output HDMI1 --mode 1920x1080 --gamma 1.3:1.3:1.3
elif [[ $hostname == 'archnuc' ]]; then
  xrandr --output HDMI1 --mode 1920x1080
fi

exec i3
