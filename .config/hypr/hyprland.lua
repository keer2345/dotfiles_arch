-- #######################################################################################
-- Hyprland 配置（Lua 版）—— 主入口
-- 文档：https://wiki.hypr.land/Configuring/
--
-- 注意：Hyprland 0.55+ 使用 Lua 配置，hyprland.lua 的优先级高于 hyprland.conf。
--       只要本文件存在，hyprland.conf 就不会被加载 —— 改配置请改这里。
--
-- 配置已拆分（本目录下，按需编辑）：
--   vars.lua    共享变量（主修饰键、终端、菜单、脚本目录）
--   theme.lua   间距/边框/圆角/阴影/模糊/动画
--   input.lua   键盘/触摸板/手势/单设备
--   rules.lua   工作区归属 + 窗口规则（浮动对话框、XWayland 拖拽、idle_inhibit）
--   binds.lua   全部按键绑定
-- 改完执行 hyprctl reload 即可；权限段有额外讲究，见文件末尾注释。
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

-- 工作区归属在 rules.lua
-- 显示器放在 require 之前：rules.lua 里的 workspace_rule 引用了显示器名字

------------------
--- MODULES ------
------------------

require("theme")
require("input")
require("rules")
require("binds")

------------------
--- AUTOSTART -----
------------------

-- https://wiki.hypr.land/Configuring/Autostart/
hl.on("hyprland.start", function()
    hl.exec_cmd("systemctl --user start wallpaper-changer.service")
    -- waybar-git 原生支持 Hyprland 0.57 的 Lua dispatch 协议，无需 PATH 兼容层
    hl.exec_cmd("waybar")
    hl.exec_cmd("nm-applet")
    hl.exec_cmd("flclash")
    hl.exec_cmd("fcitx5 --replace -d")
    hl.exec_cmd("udiskie")
    -- 音量/亮度 OSD（GTK 层壳气泡）。--top-margin 0.88 让它出现在底部上方一点，
    -- -d 1200 是显示时长（毫秒）
    hl.exec_cmd("swayosd-server --top-margin 0.88 -d 1200")
    -- 空闲管理：调光 / 键盘背光 / 锁屏 / 关屏 / 挂起，配置见 hypridle.conf
    hl.exec_cmd("hypridle")

    -- 权限兜底：开机那一次加载里 enforce_permissions 是「刚被打开」的状态，
    -- 同一次加载中注册的 hl.permission 规则会被丢掉（截图会卡住等授权）。
    -- 因此启动 2 秒后补一次 reload，让权限规则真正落库。
    -- 上游修好后可以删掉这一行；本行也只在 hyprland.start 时执行一次
    -- （hyprctl reload 不会重新触发 hyprland.start，已验证不会重复拉起上面的进程）。
    hl.exec_cmd("sh -c 'sleep 2; hyprctl reload >/dev/null 2>&1'")
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

-- 0.57 新特性：敏感操作按二进制路径授权，弹窗由 hyprland-guiutils 提供（本机已装 0.2.2）
-- 文档：https://wiki.hypr.land/configuring/core/advanced-configuration/permissions/
--
-- 默认行为（未开 enforce_permissions 时）：不检查，任何程序都能读屏。
-- 开启后各类型的默认值：screencopy=ask / plugin=ask / cursorpos=ask /
--                        keyboard=allow / input-capture=ask
--
-- 实测行为（重要）：官方文档说「权限改动需重启 Hyprland」，实测 hyprctl reload 也会应用，
-- 但「把开关从 false 打开的那一次加载」里 hl.permission 注册的规则会被丢掉 ——
-- 表现是 grim 卡住不返回（在等一个没人应答的授权框），再 reload 一次就正常。
-- 见 AUTOSTART 段末尾的兜底 reload。
hl.config({ ecosystem = { enforce_permissions = true } })

-- 截图（screencopy）—— 放行日常要用的几个，其余保持 ask（会弹窗询问）
--   shot.sh 走 grim；hyprpicker 取色；hyprlock 用 path=screenshot 做锁屏背景
-- 路径写成正则（与上游模板一致，已验证可用）
hl.permission({ binary = "/usr/(bin|local/bin)/grim", type = "screencopy", mode = "allow" })
hl.permission({ binary = "/usr/(bin|local/bin)/hyprpicker", type = "screencopy", mode = "allow" })
hl.permission({ binary = "/usr/(bin|local/bin)/hyprlock", type = "screencopy", mode = "allow" })
-- 门户后端 + 共享选择器（浏览器 / OBS 共享屏幕走这里）
hl.permission({ binary = "/usr/(lib|libexec|lib64)/xdg-desktop-portal-hyprland", type = "screencopy", mode = "allow" })
hl.permission({ binary = "/usr/(bin|local/bin)/hyprland-share-picker", type = "screencopy", mode = "allow" })

-- 光标位置：hyprpicker 要跟踪指针才能取色，默认 ask 会卡在没人应答的弹窗上
hl.permission({ binary = "/usr/(bin|local/bin)/hyprpicker", type = "cursorpos", mode = "allow" })

-- 插件：官方 hyprpm 放行（本机未装 hyprpm，留着备用）；
-- hyprctl 直接 load 插件一律拒绝，防止 `hyprctl plugin load /tmp/xxx.so` 注入
hl.permission({ binary = "/usr/(bin|local/bin)/hyprpm", type = "plugin", mode = "allow" })
hl.permission({ binary = "/usr/(bin|local/bin)/hyprctl", type = "plugin", mode = "deny" })

-- 想要「任何程序都允许读屏」的宽松做法（不建议，仅备查）：
-- hl.permission({ binary = ".*", type = "screencopy", mode = "allow" })

-- 想要「任何程序都允许读屏」的宽松做法（不建议，仅备查）：
-- hl.permission({ binary = ".*", type = "screencopy", mode = "allow" })
