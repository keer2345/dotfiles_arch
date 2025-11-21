#!/bin/bash

# 检查 eDP-1 当前状态
CURRENT_STATE=$(hyprctl monitors | grep "eDP-1" -A 5 | grep "eDP-1" | wc -l)

# 在有外接显示器的时候才能关闭笔记本屏幕
if xrandr | grep -q "^DP-1 connected"; then
    if [ $CURRENT_STATE -eq 1 ]; then
        # 如果已启用，则禁用
        hyprctl keyword monitor "eDP-1,disable"
        notify-send "显示器" "笔记本屏幕已禁用"
    else
        # 如果已禁用，则启用
        hyprctl keyword monitor "eDP-1, 1920x1200, 0x0, 1"
        notify-send "显示器" "笔记本屏幕已启用"
    fi
fi
