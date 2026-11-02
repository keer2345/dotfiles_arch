-- 输入：键盘 / 触摸板 / 手势 / 单设备配置
-- 由主文件 require("input") 加载
-- 文档：https://wiki.hypr.land/Configuring/Variables/#input

hl.config({
    input = {
        kb_layout = "us",
        kb_variant = "",
        kb_model = "",
        kb_options = "",
        kb_rules = "",

        -- 打开数字键盘
        numlock_by_default = true,

        follow_mouse = 1,

        sensitivity = 0, -- -1.0 - 1.0，0 表示不做修正

        touchpad = {
            natural_scroll = true, -- true=自然滚动，false=传统滚动
            disable_while_typing = true, -- 打字时禁用触摸板
            clickfinger_behavior = true, -- 点击区域手势
            tap_to_click = true, -- 轻触点击
            drag_lock = false, -- 拖拽锁定
        },
    },
})

-- 三指横滑切换工作区
-- https://wiki.hypr.land/Configuring/Gestures
hl.gesture({
    fingers = 3,
    direction = "horizontal",
    action = "workspace",
})

-- 单设备配置，见 https://wiki.hypr.land/Configuring/Keywords/#per-device-input-configs
-- 真实设备名用 `hyprctl devices` 查（模板里的 epic-mouse-v1 是示例，从未生效过）
-- sensitivity：0 = 不做修正；想让触摸板更慢可改成 -0.5，更快可设正值
hl.device({
    name = "msft0001:00-06cb:ce44-touchpad",
    sensitivity = 0,
    -- scroll_factor = 1.0,   -- 滚动速度倍数
    -- tap_to_click = true,   -- 也可以在这里按设备单独覆盖
})
