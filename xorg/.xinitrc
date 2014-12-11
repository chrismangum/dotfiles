#!/bin/bash

if [ -d /etc/X11/xinit/xinitrc.d ]; then
  for f in /etc/X11/xinit/xinitrc.d/*; do
    [ -x "$f" ] && . "$f"
  done
  unset f
fi

xrdb "${HOME}/.Xresources"
xflux -l 36 -g -79
xscreensaver -no-splash &

if [[ $(hostname) == 'archtop' ]]; then
  xrandr --output LVDS1 --mode 1280x800 --left-of HDMI1 --output HDMI1 --mode 1920x1080
elif [[ $(hostname) == 'archbox' ]]; then
  xrandr --output DVI-D-0 --mode 1920x1080 --rate 144
elif [[ $(hostname) == 'archnuc' ]]; then
  xrandr --output DP1 --mode 1920x1080 --rate 144
fi

exec i3
