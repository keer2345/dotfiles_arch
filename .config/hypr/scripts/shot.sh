#!/bin/sh
# 截图脚本：区域 / 全屏 / 当前窗口
#
# 用法： shot.sh area|full|window
# 产物： ~/Pictures/Screenshots/日期_时间.png，同时写入剪贴板，并弹一条 Hyprland 通知
#
# 依赖：grim slurp wl-copy jq（均已安装）

set -u

mode="${1:-area}"
dir="$HOME/Pictures/Screenshots"
mkdir -p "$dir" || exit 1
file="$dir/$(date +%Y-%m-%d_%H-%M-%S).png"

notify() {
    hyprctl notify -1 1200 0 "$1" >/dev/null 2>&1
}

case "$mode" in
    area)
        # Esc / 右键取消时 slurp 返回非零，静默退出
        geo="$(slurp 2>/dev/null)" || exit 0
        [ -n "$geo" ] || exit 0
        grim -g "$geo" "$file" || { notify "截图失败"; exit 1; }
        ;;
    full)
        grim "$file" || { notify "截图失败"; exit 1; }
        ;;
    window)
        geo="$(hyprctl -j activewindow 2>/dev/null \
            | jq -r 'if (.at and .size) then "\(.at[0]),\(.at[1]) \(.size[0])x\(.size[1])" else empty end')"

        # 焦点在 layer surface 或弹出层上时，activewindow 会是空对象，
        # 此时退回「最近聚焦过且可见」的窗口（focusHistoryID == 0）
        if [ -z "$geo" ]; then
            geo="$(hyprctl -j clients 2>/dev/null \
                | jq -r '[.[] | select(.focusHistoryID == 0 and .mapped and (.hidden | not))]
                         | first
                         | if . then "\(.at[0]),\(.at[1]) \(.size[0])x\(.size[1])" else empty end')"
        fi

        if [ -z "$geo" ]; then
            notify "没有可用窗口"
            exit 1
        fi
        grim -g "$geo" "$file" || { notify "截图失败"; exit 1; }
        ;;
    *)
        echo "用法: $0 area|full|window" >&2
        exit 2
        ;;
esac

wl-copy < "$file" || { notify "已存文件，但写入剪贴板失败"; exit 1; }
notify "已复制: $(basename "$file")"
