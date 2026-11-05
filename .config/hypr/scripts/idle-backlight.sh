#!/bin/sh
# idle-backlight.sh —— hypridle 调光 / 恢复的可靠版本
#
# 为什么不用 brightnessctl 的 -s / -r：
#   1. -s 把「改动前亮度」写进 /run/user/$UID/brightnessctl/backlight/<dev>，这个文件
#      在 hypridle 重启后依然存在。如果 hypridle 是在「已调暗」状态下被重启的，下一次
#      -s 就会把 10% 写进去，此后 -r 永远恢复到 10% —— 表现为亮度再也回不到 100%。
#   2. -r 在没有保存文件时 **退出码是 0**（只打印当前亮度，什么都不做），
#      所以 `brightnessctl -r || brightnessctl set 100%` 这种兜底根本不会触发。
#
# 本脚本自己维护状态，并且只在「当前亮度高于调暗目标」时才记录，
# 这样即使 hypridle 在已调暗状态下重启，也不会把调暗值覆盖进状态文件。
#
# 用法：
#   idle-backlight.sh dim     [device] [target%]   默认 device = 第一个 backlight，target = 10
#   idle-backlight.sh restore [device]             恢复到记录值，无记录则 100%

set -u

ACTION="${1:-}"
DEVICE="${2:-}"
TARGET="${3:-10}"

if [ -z "$DEVICE" ]; then
    DEVICE=$(brightnessctl -m -l 2>/dev/null | awk -F, '$2 == "backlight" { print $1; exit }')
fi
if [ -z "$DEVICE" ]; then
    echo "idle-backlight: 找不到背光设备" >&2
    exit 1
fi

RUN="${XDG_RUNTIME_DIR:-/run/user/$(id -u)}"
SAFE=$(printf '%s' "$DEVICE" | tr -c 'A-Za-z0-9._-' '_')
STATEDIR="$RUN/hypr-idle-backlight"
STATE="$STATEDIR/$SAFE"

CUR=$(brightnessctl -m -d "$DEVICE" get 2>/dev/null)
MAX=$(brightnessctl -m -d "$DEVICE" max 2>/dev/null)
if [ -z "$CUR" ] || [ -z "$MAX" ]; then
    echo "idle-backlight: 读不到 $DEVICE 的亮度" >&2
    exit 1
fi

case "$ACTION" in
dim)
    # 留 2% 容差：`set 10%` 在 max=65535 上会向上取整成 6554，
    # 而 MAX*10/100 = 6553，不留容差就会把「刚被调暗的值」误判成原值记录下来。
    LIMIT=$((MAX * (TARGET + 2) / 100))
    # 记录条件：还没有记录过，或当前亮度明显高于调暗目标。
    #   - 有记录 + 当前已在暗位 → 说明是「调暗后被重复触发/重启」，保持原记录（防污染）
    #   - 没有记录 + 当前很低 → 用户本来就把亮度调得很低，如实记录，别让他回来后跳到 100%
    if [ ! -s "$STATE" ] || [ "$CUR" -gt "$LIMIT" ]; then
        mkdir -p "$STATEDIR"
        printf '%s\n' "$CUR" >"$STATE"
    fi
    exec brightnessctl -d "$DEVICE" set "${TARGET}%"
    ;;
restore)
    if [ -s "$STATE" ]; then
        exec brightnessctl -d "$DEVICE" set "$(cat "$STATE")"
    fi
    exec brightnessctl -d "$DEVICE" set 100%
    ;;
*)
    echo "usage: $0 dim|restore [device] [target%]" >&2
    exit 2
    ;;
esac
