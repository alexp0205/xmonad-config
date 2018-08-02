#!/usr/bin/env sh

# Terminate already running bar instances
killall -q polybar

# Wait until the processes have been shut down
while pgrep -u $UID -x polybar >/dev/null; do sleep 1; done

# Launch left monitor and right monitor bars
polybar leftbar &
monitorCount=$(polybar --list-monitors | wc -l)
if [ "$monitorCount" -gt "1" ]
then
  polybar rightbar &
fi

echo "Bars launched..."