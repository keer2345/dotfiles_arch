#!/bin/sh
# 屏幕取色：hyprpicker -a 会把选中的颜色写进剪贴板，
# 这里再从剪贴板读回来，用 Hyprland 内置通知（hyprctl notify）提示色值。
# 说明：不用 hyprpicker 的 stdout，也不依赖 notify-send（本机没有通知守护进程）。

hyprpicker -a -f hex >/dev/null 2>&1 || exit 0   # ESC / 右键取消时返回非零，静默退出

color="$(wl-paste -n 2>/dev/null)"
if [ -n "$color" ]; then
    hyprctl notify -1 2200 0 "取色 $color 已复制"
else
    hyprctl notify -1 2000 0 "取色完成，已复制到剪贴板"
fi
