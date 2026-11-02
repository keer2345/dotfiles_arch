-- 工作区规则 + 窗口规则
-- 由主文件 require("rules") 加载
-- 文档：https://wiki.hypr.land/configuring/core/rules/

--------------------------------
---- 工作区 → 显示器归属 ------
--------------------------------

-- 1-5 在内屏 eDP-1，6-10 在外接屏 DP-1，工作区 1 同时是 eDP-1 的默认工作区
hl.workspace_rule({ workspace = "1", monitor = "eDP-1", default = true })
for i = 2, 5 do
    hl.workspace_rule({ workspace = tostring(i), monitor = "eDP-1" })
end
for i = 6, 10 do
    hl.workspace_rule({ workspace = tostring(i), monitor = "DP-1" })
end

-- 注意：SUPER + F5..F8 绑的是工作区 11-14，但这四个还没有归属规则，
-- 两块屏都在时会跟着焦点跑。需要固定的话取消注释下面两行：
-- for i = 11, 14 do
--     hl.workspace_rule({ workspace = tostring(i), monitor = "DP-1" })
-- end

--------------------------------
---- 窗口规则 ----------------
--------------------------------

-- 1) 浮动对话框：这类窗口平铺起来很难看（设置面板、混音器、文件选择框…）
--    center 只在 float 生效时起作用
local floatDialogs = {
    { "float-pavucontrol", "^(pavucontrol|org\\.pulseaudio\\.pavucontrol)$" },
    { "float-blueman", "^(blueman-manager|blueman-adapters)$" },
    { "float-nm-editor", "^(nm-connection-editor)$" },
    { "float-portal-gtk", "^(xdg-desktop-portal-gtk)$" }, -- GTK 文件选择 / 门户对话框
    { "float-share-picker", "^(hyprland-share-picker)$" }, -- 屏幕共享选择器
}
for _, r in ipairs(floatDialogs) do
    hl.window_rule({ name = r[1], match = { class = r[2] }, float = true, center = true })
end

-- 所有 modal（「确定吗」这类弹窗）一律浮动并居中；
-- 不想要可以改成 hl.window_rule(...):set_enabled(false) 的方式单独关掉
hl.window_rule({ name = "float-modals", match = { modal = true }, float = true, center = true })

-- 2) GPG / 密码输入框：浮动 + 居中还不够，必须保持焦点，否则输入会丢
hl.window_rule({
    name = "pinentry-stay-focused",
    match = { class = "^(pinentry-)(.*)" },
    float = true,
    center = true,
    stay_focused = true,
})

-- 3) 修 XWayland 拖拽残影：拖拽期间会出现一个空的浮动窗口，抢占焦点会让
--    鼠标卡住。原 hyprland.conf 里就有这条模板，之前一直是注释状态
hl.window_rule({
    name = "fix-xwayland-drags",
    match = {
        class = "^$",
        title = "^$",
        xwayland = true,
        float = true,
        fullscreen = false,
        pin = false,
    },
    no_focus = true,
})

-- 4) 全屏播放视频时不要触发空闲调光/锁屏
--    idle_inhibit 取值：none / always / focus / fullscreen
--    这里用 fullscreen：只有全屏播放才抑制，看网页时不影响 hypridle 计时
local videoApps = {
    "^(firefox|firefox-developer-edition|librewolf)$",
    "^(chromium|google-chrome|brave-browser|microsoft-edge)$",
    "^(mpv|vlc|celluloid|io.github.celluloid_player.Celluloid)$",
    "^(org\\.telegram\\.desktop|spotify)$",
}
for _, cls in ipairs(videoApps) do
    hl.window_rule({ match = { class = cls }, idle_inhibit = "fullscreen" })
end

-- 5) 备选：忽略所有最大化请求（很多应用会莫名其妙自最大化，平铺下没意义）
--    原配置里就是注释状态，需要时取消注释
-- hl.window_rule({ name = "suppress-maximize-events", match = { class = ".*" }, suppress_event = "maximize" })

-- 6) 备选："Smart gaps" / "No gaps when only"（全屏单窗口时去掉间隙）
-- hl.workspace_rule({ workspace = "w[tv1]", gaps_out = 0, gaps_in = 0 })
-- hl.workspace_rule({ workspace = "f[1]",   gaps_out = 0, gaps_in = 0 })
-- hl.window_rule({ name = "no-gaps-wtv1", match = { float = false, workspace = "w[tv1]" }, border_size = 0, rounding = 0 })
-- hl.window_rule({ name = "no-gaps-f1",   match = { float = false, workspace = "f[1]" },   border_size = 0, rounding = 0 })
