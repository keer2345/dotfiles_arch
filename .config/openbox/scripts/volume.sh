#!/bin/bash
# ~/.config/openbox/scripts/volume.sh

action=$1
step=5%

case $action in
    "up")
        pactl set-sink-volume @DEFAULT_SINK@ +$step
        ;;
    "down")
        pactl set-sink-volume @DEFAULT_SINK@ -$step
        ;;
    "toggle")
        pactl set-sink-mute @DEFAULT_SINK@ toggle
        ;;
    *)
        echo "Usage: $0 {up|down|toggle}"
        exit 1
        ;;
esac

# 获取当前音量状态并显示通知
vol=$(pactl get-sink-volume @DEFAULT_SINK@ | head -n1 | awk '{print $5}')
mute=$(pactl get-sink-mute @DEFAULT_SINK@ | awk '{print $2}')

if [ "$mute" = "yes" ]; then
    notify-send -t 1000 "音量" "静音中"
else
    notify-send -t 1000 "音量" "当前: $vol"
fi
