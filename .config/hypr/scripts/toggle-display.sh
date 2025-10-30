#!/bin/bash

# 检查 eDP-1 当前状态
CURRENT_STATE=$(hyprctl monitors | grep "eDP-1" -A 5 | grep "eDP-1" | wc -l)

if [ $CURRENT_STATE -eq 1 ]; then
    # 如果已启用，则禁用
    hyprctl keyword monitor "eDP-1,disable"
    notify-send "显示器" "笔记本屏幕已禁用"

    # 工作区绑定
    hyprctl keyword workspace=1, monitor:DP-1, default:true
    hyprctl keyword workspace=2, monitor:DP-1
    hyprctl keyword workspace=3, monitor:DP-1
    hyprctl keyword workspace=4, monitor:DP-1
    hyprctl keyword workspace=5, monitor:DP-1

else
    # 如果已禁用，则启用
    hyprctl keyword monitor "eDP-1, 1920x1200, 0x0, 1"
    notify-send "显示器" "笔记本屏幕已启用"
fi

