#! /bin/bash

xrdb ~/.Xresources

# Caps lock is escape
setxkbmap -option caps:escape

# System tray
# trayer --edge top --align right --widthtype percent  --expand true --SetDockType true --SetPartialStrut true --transparent true --alpha 0 --tint 0x282828 --expand true --heighttype pixel --height 19 --width 8 &

# Compositing
compton &

# set wallpaper
feh --bg-fill ~/configs/linux-yoda.jpg

# Cursor will no longer be an x
xsetroot -cursor_name left_ptr

firefox &
mattermost-desktop &
telegram-desktop &

pgrep redshift-gtk &> /dev/null || redshift-gtk &> /dev/null &

eval $(/usr/bin/gnome-keyring-daemon --start --components=pkcs11,secrets,ssh)
export SSH_AUTH_SOCK

exec xmonad

