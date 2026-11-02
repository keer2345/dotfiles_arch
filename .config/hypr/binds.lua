-- 按键绑定
-- 由主文件 require("binds") 加载
-- 文档：https://wiki.hypr.land/Configuring/Binds/

local v = require("vars")
local mainMod = v.mainMod
local scripts = v.scripts

---------------------
---- 启动程序 ------
---------------------

hl.bind(mainMod .. " + T", hl.dsp.exec_cmd(v.terminal))
hl.bind(mainMod .. " + Q", hl.dsp.window.close())
hl.bind(mainMod .. " + CTRL + Q", hl.dsp.exit())
hl.bind(mainMod .. " + E", hl.dsp.exec_cmd(v.fileManager))
hl.bind(mainMod .. " + R", hl.dsp.exec_cmd(v.menu))

---------------------
---- 窗口操作 ------
---------------------

hl.bind(mainMod .. " + V", hl.dsp.window.float({ action = "toggle" }))
hl.bind(mainMod .. " + F", hl.dsp.window.fullscreen({ action = "toggle" }))
hl.bind(mainMod .. " + P", hl.dsp.window.pseudo()) -- dwindle：伪平铺开关
-- hl.bind(mainMod .. " + J", hl.dsp.layout("togglesplit")) -- dwindle（J 已被 movefocus d 占用，需要时换键）

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

---------------------
---- 工作区 ---------
---------------------

-- 1-0 切换工作区 / SHIFT + 1-0 把窗口移到工作区
for i = 1, 10 do
    local key = i % 10 -- 10 映射到按键 0
    hl.bind(mainMod .. " + " .. key, hl.dsp.focus({ workspace = i }))
    hl.bind(mainMod .. " + SHIFT + " .. key, hl.dsp.window.move({ workspace = i }))
end

-- F5-F8 切换工作区 11-14
local extraKeys = { "F5", "F6", "F7", "F8" }
for idx, key in ipairs(extraKeys) do
    local ws = 10 + idx
    hl.bind(mainMod .. " + " .. key, hl.dsp.focus({ workspace = ws }))
    hl.bind(mainMod .. " + SHIFT + " .. key, hl.dsp.window.move({ workspace = ws }))
end

-- special workspace（暂存区）
hl.bind(mainMod .. " + S", hl.dsp.workspace.toggle_special("magic"))
hl.bind(mainMod .. " + SHIFT + S", hl.dsp.window.move({ workspace = "special:magic" }))

-- SUPER + 滚轮切换工作区
hl.bind(mainMod .. " + mouse_down", hl.dsp.focus({ workspace = "e+1" }))
hl.bind(mainMod .. " + mouse_up", hl.dsp.focus({ workspace = "e-1" }))

-- SUPER + 左键拖动 / 右键缩放
hl.bind(mainMod .. " + mouse:272", hl.dsp.window.drag(), { mouse = true })
hl.bind(mainMod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })

---------------------
---- 截图 / 取色 ----
---------------------

-- 截图：存到 ~/Pictures/Screenshots 并复制到剪贴板，完成后弹一条通知
-- 脚本：scripts/shot.sh（区域 / 全屏 / 当前窗口）
hl.bind("PRINT", hl.dsp.exec_cmd(scripts .. "/shot.sh area"))
hl.bind("SHIFT + PRINT", hl.dsp.exec_cmd(scripts .. "/shot.sh full"))
hl.bind(mainMod .. " + PRINT", hl.dsp.exec_cmd(scripts .. "/shot.sh window"))

-- 屏幕取色：点哪里取哪里的颜色，hex 值直接进剪贴板并弹通知
hl.bind(mainMod .. " + C", hl.dsp.exec_cmd(scripts .. "/pick-color.sh"))

-- 开关笔记本内屏（原为 mainMod + SHIFT + P，与伪平铺 P 同键族，改到 F12 更顺手）
hl.bind(mainMod .. " + F12", hl.dsp.exec_cmd(scripts .. "/toggle-display.sh"))

---------------------
---- 音频 / 亮度 ----
---------------------

-- 统一走 swayosd-client —— 它既执行动作，又弹出 OSD 气泡
-- 音量最终仍然落在 PipeWire 上（wpctl / pavucontrol 看到的数值一致）
-- --max-volume 100 等价于原来 wpctl 的 -l 1（封顶 100%）
local volUp = "swayosd-client --output-volume raise --max-volume 100"
local volDown = "swayosd-client --output-volume lower"
local volMute = "swayosd-client --output-volume mute-toggle"
local brightUp = "swayosd-client --brightness raise"
local brightDown = "swayosd-client --brightness lower"

hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd(volUp), { locked = true, repeating = true })
hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd(volDown), { locked = true, repeating = true })
hl.bind("XF86AudioMute", hl.dsp.exec_cmd(volMute), { locked = true, repeating = true })

hl.bind(mainMod .. " + F11", hl.dsp.exec_cmd(volUp), { locked = true, repeating = true })
hl.bind(mainMod .. " + F10", hl.dsp.exec_cmd(volDown), { locked = true, repeating = true })
hl.bind(mainMod .. " + F9", hl.dsp.exec_cmd(volMute), { locked = true, repeating = true })

-- 麦克风静音：走 input-volume，OSD 图标是话筒
hl.bind(
    "XF86AudioMicMute",
    hl.dsp.exec_cmd("swayosd-client --input-volume mute-toggle"),
    { locked = true, repeating = true }
)

-- 屏幕亮度（swayosd 内部调 brightnessctl）
hl.bind("XF86MonBrightnessUp", hl.dsp.exec_cmd(brightUp), { locked = true, repeating = true })
hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd(brightDown), { locked = true, repeating = true })

-- 多媒体键（需要 playerctl）
hl.bind("XF86AudioNext", hl.dsp.exec_cmd("playerctl next"), { locked = true })
hl.bind("XF86AudioPause", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPlay", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPrev", hl.dsp.exec_cmd("playerctl previous"), { locked = true })

---------------------
---- 锁屏 -----------
---------------------

-- hyprlock：只响应 SUPER + CTRL + L
-- 注意：这里不能加 ignore_mods —— 0.57 下该标志会跳过修饰键校验，
--       结果就是单独按 l 也会触发锁屏。
hl.bind(mainMod .. " + CTRL + L", hl.dsp.exec_cmd("hyprlock"))
