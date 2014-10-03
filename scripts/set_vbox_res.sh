#!/bin/bash
if [[ $(hostname) == 'archtop' ]]; then
  modeLine=$(cvt 1280 800 | grep Modeline)
  modeName=$(echo $modeLine | cut -d ' ' -f 2)
  modeValue=$(echo $modeLine | sed 's/Modeline //')

  xrandr --newmode $modeValue
  xrandr --addmode VBOX1 $modeName
  xrandr --output VBOX1 --mode $modeName --left-of VBOX0 --output VBOX0 --mode 1920x1080
fi
