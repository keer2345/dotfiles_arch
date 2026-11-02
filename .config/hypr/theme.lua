-- 外观：间距 / 边框 / 圆角 / 阴影 / 模糊 / 动画曲线
-- 由主文件 require("theme") 加载
-- 文档：https://wiki.hypr.land/Configuring/Variables/

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

-- https://wiki.hypr.land/Configuring/Dwindle-Layout/
hl.config({
    dwindle = {
        -- pseudotile = true, -- 伪平铺总开关，绑定在 binds.lua 的 mainMod + P
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
