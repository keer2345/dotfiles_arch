-- #######################################################################################
-- Hyprland 配置（Lua 版）—— 由 ~/.config/hypr/hyprland.conf 等价迁移而来
-- 文档：https://wiki.hypr.land/Configuring/
--
-- 注意：Hyprland 0.55+ 使用 Lua 配置，hyprland.lua 的优先级高于 hyprland.conf。
--       只要本文件存在，hyprland.conf 就不会被加载 —— 改配置请改这里。
--       想拆分配置：把片段放在同目录，然后 require("myColors") 之类引用。
-- #######################################################################################

------------------
--- MONITORS -----
------------------

-- https://wiki.hypr.land/Configuring/Monitors/
hl.monitor({
    output = "eDP-1",
    mode = "1920x1200",
    position = "0x0",
    scale = 1,
})

hl.monitor({
    output = "DP-1",
    mode = "preferred",
    position = "1920x0",
    scale = 1,
})

-- 工作区绑定：1-5 在内屏，6-10 在外接屏，工作区 1 为 eDP-1 默认
hl.workspace_rule({ workspace = "1", monitor = "eDP-1", default = true })
for i = 2, 5 do
    hl.workspace_rule({ workspace = tostring(i), monitor = "eDP-1" })
end
for i = 6, 10 do
    hl.workspace_rule({ workspace = tostring(i), monitor = "DP-1" })
end

---------------------
--- MY PROGRAMS -----
---------------------

-- 常用程序
local terminal = "kitty"
local fileManager = "thunar"
local menu = "fuzzel"

------------------
--- AUTOSTART -----
------------------

-- https://wiki.hypr.land/Configuring/Autostart/
hl.on("hyprland.start", function()
    hl.exec_cmd("systemctl --user start wallpaper-changer.service")
    hl.exec_cmd("waybar")
    hl.exec_cmd("nm-applet")
    hl.exec_cmd("flclash")
    hl.exec_cmd("fcitx5 --replace -d")
    hl.exec_cmd("udiskie")
end)

-----------------------------
--- ENVIRONMENT VARIABLES -----
-----------------------------

-- https://wiki.hypr.land/Configuring/Environment-variables/
hl.env("XCURSOR_SIZE", "24")
hl.env("HYPRCURSOR_SIZE", "24")
hl.env("QT_QPA_PLATFORMTHEME", "qt6ct")

----------------------
---- PERMISSIONS ------
----------------------

-- 权限改动需要重启 Hyprland 才生效（出于安全考虑不支持热重载）
-- hl.config({ ecosystem = { enforce_permissions = true } })
-- hl.permission({ binary = "/usr/(bin|local/bin)/grim", type = "screencopy", mode = "allow" })
-- hl.permission({ binary = "/usr/(lib|libexec|lib64)/xdg-desktop-portal-hyprland", type = "screencopy", mode = "allow" })
-- hl.permission({ binary = "/usr/(bin|local/bin)/hyprpm", type = "plugin", mode = "allow" })

----------------------
---- LOOK AND FEEL ---
----------------------

-- https://wiki.hypr.land/Configuring/Variables/#general
hl.config({
    general = {
        gaps_in = 5,
        gaps_out = 10,

        border_size = 1,

        col = {
            active_border = { colors = { "rgba(121212ee)", "rgba(e8eaedea)" }, angle = 45 },
            inactive_border = "rgba(595959aa)",
        },

        -- true 时可用鼠标拖拽边框 / 间隙来调整窗口大小
        resize_on_border = false,

        -- 开启前请先看 https://wiki.hypr.land/Configuring/Tearing/
        allow_tearing = false,

        layout = "dwindle",
        -- layout = "master",
    },

    decoration = {
        rounding = 8,
        rounding_power = 2,

        -- 焦点 / 非焦点窗口透明度
        active_opacity = 1.0,
        inactive_opacity = 1.0,

        shadow = {
            enabled = true,
            range = 4,
            render_power = 3,
            color = 0xee1a1a1a,
        },

        blur = {
            enabled = true,
            size = 3,
            passes = 1,
            vibrancy = 0.1696,
        },
    },

    animations = {
        enabled = true,
    },
})

-- 贝塞尔曲线：NAME, X0, Y0, X1, Y1
hl.curve("easeOutQuint", { type = "bezier", points = { { 0.23, 1 }, { 0.32, 1 } } })
hl.curve("easeInOutCubic", { type = "bezier", points = { { 0.65, 0.05 }, { 0.36, 1 } } })
hl.curve("linear", { type = "bezier", points = { { 0, 0 }, { 1, 1 } } })
hl.curve("almostLinear", { type = "bezier", points = { { 0.5, 0.5 }, { 0.75, 1 } } })
hl.curve("quick", { type = "bezier", points = { { 0.15, 0 }, { 0.1, 1 } } })

-- 动画：leaf, enabled, speed, curve, [style]
hl.animation({ leaf = "global", enabled = true, speed = 10, bezier = "default" })
hl.animation({ leaf = "border", enabled = true, speed = 5.39, bezier = "easeOutQuint" })
hl.animation({ leaf = "windows", enabled = true, speed = 4.79, bezier = "easeOutQuint" })
hl.animation({ leaf = "windowsIn", enabled = true, speed = 4.1, bezier = "easeOutQuint", style = "popin 87%" })
hl.animation({ leaf = "windowsOut", enabled = true, speed = 1.49, bezier = "linear", style = "popin 87%" })
hl.animation({ leaf = "fadeIn", enabled = true, speed = 1.73, bezier = "almostLinear" })
hl.animation({ leaf = "fadeOut", enabled = true, speed = 1.46, bezier = "almostLinear" })
hl.animation({ leaf = "fade", enabled = true, speed = 3.03, bezier = "quick" })
hl.animation({ leaf = "layers", enabled = true, speed = 3.81, bezier = "easeOutQuint" })
hl.animation({ leaf = "layersIn", enabled = true, speed = 4, bezier = "easeOutQuint", style = "fade" })
hl.animation({ leaf = "layersOut", enabled = true, speed = 1.5, bezier = "linear", style = "fade" })
hl.animation({ leaf = "fadeLayersIn", enabled = true, speed = 1.79, bezier = "almostLinear" })
hl.animation({ leaf = "fadeLayersOut", enabled = true, speed = 1.39, bezier = "almostLinear" })
hl.animation({ leaf = "workspaces", enabled = true, speed = 1.94, bezier = "almostLinear", style = "fade" })
hl.animation({ leaf = "workspacesIn", enabled = true, speed = 1.21, bezier = "almostLinear", style = "fade" })
hl.animation({ leaf = "workspacesOut", enabled = true, speed = 1.94, bezier = "almostLinear", style = "fade" })
hl.animation({ leaf = "zoomFactor", enabled = true, speed = 7, bezier = "quick" })

-- "Smart gaps" / "No gaps when only"（按需取消注释）
-- hl.workspace_rule({ workspace = "w[tv1]", gaps_out = 0, gaps_in = 0 })
-- hl.workspace_rule({ workspace = "f[1]",   gaps_out = 0, gaps_in = 0 })
-- hl.window_rule({ name = "no-gaps-wtv1", match = { float = false, workspace = "w[tv1]" }, border_size = 0, rounding = 0 })
-- hl.window_rule({ name = "no-gaps-f1",   match = { float = false, workspace = "f[1]" },   border_size = 0, rounding = 0 })

-- https://wiki.hypr.land/Configuring/Dwindle-Layout/
hl.config({
    dwindle = {
        -- pseudotile = true, -- 伪平铺总开关，绑定在下面的 mainMod + P
        preserve_split = true, -- 建议保持开启
    },
})

-- https://wiki.hypr.land/Configuring/Master-Layout/
hl.config({
    master = {
        new_status = "master",
    },
})

-- https://wiki.hypr.land/Configuring/Variables/#misc
hl.config({
    misc = {
        force_default_wallpaper = -1, -- 设为 0 或 1 可禁用二次元壁纸
        disable_hyprland_logo = false, -- true 可禁用随机 Hyprland logo / 二次元背景
    },
})

---------------
--- INPUT -----
---------------

-- https://wiki.hypr.land/Configuring/Variables/#input
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
            drag_lock = false,  -- 拖拽锁定
        },
    },
})

-- https://wiki.hypr.land/Configuring/Gestures
hl.gesture({
    fingers = 3,
    direction = "horizontal",
    action = "workspace",
})

-- 单设备配置，见 https://wiki.hypr.land/Configuring/Keywords/#per-device-input-configs
hl.device({
    name = "epic-mouse-v1",
    sensitivity = -0.5,
})

---------------------
--- KEYBINDINGS -----
---------------------

-- https://wiki.hypr.land/Configuring/Binds/
local mainMod = "SUPER" -- 以 Windows 键作为主修饰键

hl.bind(mainMod .. " + T", hl.dsp.exec_cmd(terminal))
hl.bind(mainMod .. " + Q", hl.dsp.window.close())
hl.bind(mainMod .. " + CTRL + Q", hl.dsp.exit())
hl.bind(mainMod .. " + E", hl.dsp.exec_cmd(fileManager))
hl.bind(mainMod .. " + V", hl.dsp.window.float({ action = "toggle" }))
hl.bind(mainMod .. " + R", hl.dsp.exec_cmd(menu))
hl.bind(mainMod .. " + F", hl.dsp.window.fullscreen({ action = "toggle" }))
-- hl.bind(mainMod .. " + P", hl.dsp.window.pseudo())    -- dwindle
-- hl.bind(mainMod .. " + J", hl.dsp.layout("togglesplit")) -- dwindle

-- SUPER + G：把当前窗口调整为 屏宽 50% / 屏高 100%
-- 对应原来的 hyprctl dispatch resizeactive exact 50% 100%（0.57 已移除旧式 dispatcher）
hl.bind(mainMod .. " + G", function()
    local win = hl.get_active_window()
    if not win or not win.monitor then
        return
    end
    local mon = win.monitor
    hl.dispatch(hl.dsp.window.resize({
        x = math.floor(mon.width / mon.scale * 0.5),
        y = math.floor(mon.height / mon.scale),
    }))
end)

-- H/J/K/L 移动焦点（vim 风格）
hl.bind(mainMod .. " + H", hl.dsp.focus({ direction = "l" }))
hl.bind(mainMod .. " + L", hl.dsp.focus({ direction = "r" }))
hl.bind(mainMod .. " + K", hl.dsp.focus({ direction = "u" }))
hl.bind(mainMod .. " + J", hl.dsp.focus({ direction = "d" }))

-- SHIFT + H/J/K/L 移动窗口
hl.bind(mainMod .. " + SHIFT + H", hl.dsp.window.move({ direction = "l" }))
hl.bind(mainMod .. " + SHIFT + L", hl.dsp.window.move({ direction = "r" }))
hl.bind(mainMod .. " + SHIFT + K", hl.dsp.window.move({ direction = "u" }))
hl.bind(mainMod .. " + SHIFT + J", hl.dsp.window.move({ direction = "d" }))

-- 1-0 切换工作区 / SHIFT + 1-0 把窗口移到工作区
for i = 1, 10 do
    local key = i % 10 -- 10 映射到按键 0
    hl.bind(mainMod .. " + " .. key, hl.dsp.focus({ workspace = i }))
    hl.bind(mainMod .. " + SHIFT + " .. key, hl.dsp.window.move({ workspace = i }))
end

-- F5-F8 切换到工作区 11-14
local extraKeys = { "F5", "F6", "F7", "F8" }
for idx, key in ipairs(extraKeys) do
    local ws = 10 + idx
    hl.bind(mainMod .. " + " .. key, hl.dsp.focus({ workspace = ws }))
    hl.bind(mainMod .. " + SHIFT + " .. key, hl.dsp.window.move({ workspace = ws }))
end

-- 开关笔记本内屏
hl.bind(mainMod .. " + SHIFT + P", hl.dsp.exec_cmd("~/.config/hypr/scripts/toggle-display.sh"))

-- special workspace（暂存区）
hl.bind(mainMod .. " + S", hl.dsp.workspace.toggle_special("magic"))
hl.bind(mainMod .. " + SHIFT + S", hl.dsp.window.move({ workspace = "special:magic" }))

-- SUPER + 滚轮切换工作区
hl.bind(mainMod .. " + mouse_down", hl.dsp.focus({ workspace = "e+1" }))
hl.bind(mainMod .. " + mouse_up", hl.dsp.focus({ workspace = "e-1" }))

-- SUPER + 左键拖动 / 右键缩放
hl.bind(mainMod .. " + mouse:272", hl.dsp.window.drag(), { mouse = true })
hl.bind(mainMod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })

-- 音量 / 亮度（bindel = locked + repeating）
hl.bind(
    "XF86AudioRaiseVolume",
    hl.dsp.exec_cmd("wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+"),
    { locked = true, repeating = true }
)
hl.bind(
    "XF86AudioLowerVolume",
    hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"),
    { locked = true, repeating = true }
)
hl.bind(
    "XF86AudioMute",
    hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"),
    { locked = true, repeating = true }
)

hl.bind(
    mainMod .. " + F11",
    hl.dsp.exec_cmd("wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+"),
    { locked = true, repeating = true }
)
hl.bind(
    mainMod .. " + F10",
    hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"),
    { locked = true, repeating = true }
)
hl.bind(
    mainMod .. " + F9",
    hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"),
    { locked = true, repeating = true }
)

hl.bind(
    "XF86AudioMicMute",
    hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"),
    { locked = true, repeating = true }
)
hl.bind("XF86MonBrightnessUp", hl.dsp.exec_cmd("brightnessctl -e4 -n2 set 5%+"), { locked = true, repeating = true })
hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd("brightnessctl -e4 -n2 set 5%-"), { locked = true, repeating = true })

-- 多媒体键（需要 playerctl）
hl.bind("XF86AudioNext", hl.dsp.exec_cmd("playerctl next"), { locked = true })
hl.bind("XF86AudioPause", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPlay", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPrev", hl.dsp.exec_cmd("playerctl previous"), { locked = true })

-- hyprlock：只响应 SUPER + CTRL + L
-- 注意：这里不能加 ignore_mods —— 0.57 下该标志会跳过修饰键校验，
--       结果就是单独按 l 也会触发锁屏。
-- hl.bind("SUPER + CTRL + L", hl.dsp.exec_cmd("hyprlock"))
hl.bind(mainMod .. " + CTRL + L", hl.dsp.exec_cmd("hyprlock"))

-------------------------------
--- WINDOWS AND WORKSPACES -----
-------------------------------

-- https://wiki.hypr.land/Configuring/Window-Rules/
-- https://wiki.hypr.land/Configuring/Workspace-Rules/

-- 原配置中这两条规则是注释状态，保持默认不启用；需要时取消注释即可
--
-- hl.window_rule({
--     name          = "suppress-maximize-events",
--     match         = { class = ".*" },
--     suppress_event = "maximize",
-- })
--
-- hl.window_rule({
--     name  = "fix-xwayland-drags",
--     match = { class = "^$", title = "^$", xwayland = true, float = true, fullscreen = false, pin = false },
--     no_focus = true,
-- })

-- 窗口规则示例：
-- hl.window_rule({ name = "float-kitty", match = { class = "^(kitty)$" }, float = true })
