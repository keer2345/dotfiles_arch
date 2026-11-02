#!/bin/sh
# 笔记本内屏（eDP-1）开关 —— 绑定 SUPER + SHIFT + P
#
# 为什么重写（迁移到 Lua 配置后失效的两个原因）：
#   1. Hyprland 0.57 的 Lua 模式下 `hyprctl keyword` 已废除，执行只返回
#      "unknown request"，所以原来那两行 `keyword monitor ...` 全是空操作
#      —— 按键通了、脚本也跑了，但屏幕纹丝不动。
#   2. 原来的状态判断靠 `hyprctl monitors` 的文本输出 + 行数统计，非常脆；
#      改用 `hyprctl -j monitors all` 的 JSON，disabled 字段直接可读。
#
# 现在的做法：读 JSON 判断状态 -> 用 `hyprctl eval` 下发 hl.monitor() 规则。
# 注意重新启用时【必须显式写 disabled = false】：
#   实测只给 output/mode/position 时，已有的 disabled=true 会继续生效，
#   屏幕不会回来；必须显式置 false 才会重新启用。

set -u

INT=eDP-1          # 笔记本内屏
MODE=1920x1200     # 与 hyprland.lua 里的 monitor 配置保持一致
POS=0x0
SCALE=1

notify() { hyprctl notify -1 1800 0 "$1" >/dev/null 2>&1; }

# 当前状态：true=已禁用 / false=已启用 / missing=完全不在列表里（例如未接/合盖）
state=$(hyprctl -j monitors all 2>/dev/null \
    | jq -r --arg m "$INT" '[.[] | select(.name == $m)][0]
        | if . == null then "missing" else (.disabled | tostring) end')

if [ -z "$state" ]; then
    notify "读取显示器状态失败"
    exit 1
fi

# 已启用的外接显示器数量（排除内屏本身与 HEADLESS-* 虚拟输出）
ext=$(hyprctl -j monitors 2>/dev/null \
    | jq -r --arg m "$INT" '[.[] | select(.name != $m)
        | select(.name | startswith("HEADLESS-") | not)] | length')

# $1 = disabled 的取值：true / false
apply() {
    hyprctl eval "hl.monitor({ output = \"$INT\", mode = \"$MODE\", position = \"$POS\", scale = $SCALE, disabled = $1 })" 2>&1
}

# hyprctl eval 成功时输出 "ok"，失败时输出错误文本且退出码仍为 0，所以要判内容
run_apply() {
    out=$(apply "$1")
    case "$out" in
        *ok*) return 0 ;;
        *)    notify "切换失败：$out"; exit 1 ;;
    esac
}

if [ "$state" = "false" ]; then
    # 当前是启用状态 -> 准备关闭，但必须先确认有外接屏，否则会把自己锁在无界面状态
    if [ "${ext:-0}" -lt 1 ]; then
        notify "没有外接显示器，笔记本内屏保持开启"
        exit 0
    fi
    run_apply true && notify "笔记本内屏已关闭"
else
    # 已禁用 / 不在列表 -> 重新启用
    run_apply false && notify "笔记本内屏已开启"
fi
