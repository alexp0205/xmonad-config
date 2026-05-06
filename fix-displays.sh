#!/usr/bin/env bash

autorandr --change --force
$HOME/configs/xmonad-config/polybar/launch.sh
xmonad --restart
