# Hyprland 配置说明

本机 Hyprland **0.57.0** 的配置文档。0.55 起 Hyprland 改用 Lua 配置，本目录的
`hyprland.lua` 是唯一入口，`hyprland.conf` 已不再被加载（保留作历史参考）。

- 整理日期：2026-11-02
- 机器：Lenovo Yoga 14s ACH 2021（Renoir / Ryzen 核显）
- 显示器：`eDP-1` 1920x1200 内屏 + `DP-1` 外接屏
- 布局：dwindle；面板 waybar；终端 kitty；启动器 fuzzel

---

## 1. 改配置的标准流程

```bash
# 1) 改完之后先查语法
luac -p ~/.config/hypr/*.lua

# 2) 热重载（不重启会话，窗口不会掉）
hyprctl reload

# 3) 必须确认没有报错
hyprctl configerrors          # 期望输出为空

# 4) 抽查实际生效值（配置写错时这里会显示旧值）
hyprctl -j getoption general:gaps_out
```

三条硬规则：

1. **`require` 失败 = 整份配置失效**。模块里写错一个 API，reload 后所有绑定会一起消失。
   改动结构（拆文件、加 `require`）时不要直接 reload 试错，先用第 7 节的假 `hl`
   校验器跑一遍。
2. **改完必须看一眼 `configerrors`**。它是空的才说明解析通过；有输出时 Hyprland 会
   保留上一份可用配置继续跑，表面上「像是生效了」，很容易误判。
3. **权限段（`hyprland.lua` 的 PERMISSIONS）有额外讲究**，见 6.6。

---

## 2. 目录结构

| 文件 | 行数 | 内容 |
|---|---:|---|
| `hyprland.lua` | 120 | 主入口：显示器、autostart、环境变量、权限 |
| `vars.lua` | 11 | 共享变量（主修饰键、终端、文件管理器、菜单、脚本目录） |
| `theme.lua` | 103 | 间距、边框、圆角、阴影、模糊、5 条贝塞尔曲线、17 条动画 |
| `input.lua` | 46 | 键盘、触摸板、三指手势、单设备（触摸板灵敏度） |
| `rules.lua` | 90 | 工作区归属 10 条 + 窗口规则 12 条 |
| `binds.lua` | 146 | 全部按键绑定（运行时 70 条） |
| `hypridle.conf` | 54 | 空闲管理（**hyprlang 语法，不是 Lua**） |
| `hyprlock.conf` | 30 | 锁屏外观（hyprlang） |
| `hyprpaper.conf` | 5 | 壁纸（由 `scripts/random-wallpaper.sh` 自动生成） |
| `scripts/shot.sh` | 57 | 截图：区域 / 全屏 / 当前窗口 |
| `scripts/pick-color.sh` | 14 | 屏幕取色 |
| `scripts/toggle-display.sh` | — | 开关笔记本内屏 |
| `scripts/random-wallpaper.sh`、`change_wallpaper.sh` | — | 壁纸轮换（配合 systemd user 服务） |
| `hyprland.conf` | 388 | **历史文件，不生效**，仅作迁移前参考 |
| `README2.md` | — | 早期笔记（hyprpaper / hyprpanel 时期），部分内容已过时 |

关联的外部配置：

- `~/.config/waybar/{config.jsonc,style.css}` — 面板
- `~/.config/swayosd/style.css` — 音量/亮度 OSD 样式
- `~/.config/systemd/user/wallpaper-changer.service` — 壁纸轮换

---

## 3. 加载顺序（很重要）

```lua
-- hyprland.lua 里这个顺序不能调
hl.monitor({ output = "eDP-1", ... })
hl.monitor({ output = "DP-1",  ... })
require("theme")
require("input")
require("rules")   -- workspace_rule 引用了显示器名字
require("binds")
```

`monitors` 必须在 `require` 之前，因为 `rules.lua` 的 `workspace_rule` 里写的是
字符串 `"eDP-1"` / `"DP-1"`。模块之间用 `require("vars")` 取共享值。

`package.path` 已包含本目录，所以同目录放新模块直接 `require("名字")` 即可，不用改路径。

---

## 4. 快捷键

`SUPER` 即 Windows 键（`vars.lua` 里的 `mainMod`）。

### 程序与窗口

| 快捷键 | 动作 |
|---|---|
| `SUPER + T` | kitty 终端 |
| `SUPER + E` | thunar 文件管理器 |
| `SUPER + R` | fuzzel 启动器 |
| `SUPER + Q` | 关闭当前窗口 |
| `SUPER + CTRL + Q` | 退出 Hyprland |
| `SUPER + V` | 浮动 / 平铺切换 |
| `SUPER + F` | 全屏切换 |
| `SUPER + P` | 伪平铺（dwindle pseudo） |
| `SUPER + F12` | 关闭 / 打开笔记本内屏（须有外接屏才允许关） |
| `SUPER + G` | 当前窗口调成「屏宽 50% × 屏高 100%」 |
| `SUPER + H/J/K/L` | 焦点 左/下/上/右 |
| `SUPER + SHIFT + H/J/K/L` | 移动窗口 |
| `SUPER + 左键拖动` | 拖动窗口 |
| `SUPER + 右键拖动` | 缩放窗口 |

### 工作区

| 快捷键 | 动作 |
|---|---|
| `SUPER + 1..0` | 切到工作区 1..10 |
| `SUPER + SHIFT + 1..0` | 把窗口移到工作区 1..10 |
| `SUPER + F5..F8` | 切到工作区 11..14 |
| `SUPER + SHIFT + F5..F8` | 把窗口移到工作区 11..14 |
| `SUPER + S` | 开关 special 暂存区 `magic` |
| `SUPER + SHIFT + S` | 把窗口送进暂存区 |
| `SUPER + 滚轮` | 相对切换工作区 |

工作区归属：1-5 在 `eDP-1`，6-10 在 `DP-1`，工作区 1 是 `eDP-1` 的默认。
**11-14 目前没有归属规则**，见第 8 节。

### 截图与取色

| 快捷键 | 动作 |
|---|---|
| `PRINT` | 框选区域截图 |
| `SHIFT + PRINT` | 全屏截图 |
| `SUPER + PRINT` | 当前窗口截图 |
| `SUPER + C` | 屏幕取色（hex 进剪贴板） |

### 音频 / 亮度 / 媒体

| 快捷键 | 动作 |
|---|---|
| `SUPER + F9` / `XF86AudioMute` | 静音切换 |
| `SUPER + F10` / `XF86AudioLowerVolume` | 音量 -5% |
| `SUPER + F11` / `XF86AudioRaiseVolume` | 音量 +5%（封顶 100%） |
| `XF86AudioMicMute` | 麦克风静音 |
| `XF86MonBrightnessUp/Down` | 亮度 ± |
| `XF86AudioPlay/Pause/Next/Prev` | playerctl 媒体控制 |

以上音量/亮度键都是 `locked + repeating`（锁屏状态下也能用，按住会连续触发）。

### 锁屏

| 快捷键 | 动作 |
|---|---|
| `SUPER + CTRL + L` | hyprlock |

> 只有这一条锁屏绑定。**不要加 `ignore_mods`**，原因见 7.2。

---

## 5. 依赖组件

已安装并接入的包：

| 包 | 版本 | 用途 |
|---|---|---|
| `hyprland` | 0.57.0-1 | 本体 |
| `waybar-git` | 0.15.0.r1100 | 面板，**必须 master 版**，见 7.3 |
| `wireplumber` | 0.5.18-1 | 提供 `wpctl` + 会话管理器 |
| `pipewire-pulse`、`pipewire-audio`、`pipewire-alsa` | — | PulseAudio 兼容层、ALSA 支持 |
| `swayosd` | 0.3.2-1 | 音量/亮度 OSD 气泡 |
| `hypridle` | 0.1.8-2 | 空闲管理 |
| `hyprlock` | — | 锁屏 |
| `xdg-desktop-portal-hyprland` | — | 屏幕共享后端（ScreenCast / Screenshot） |
| `hyprland-guiutils` | 0.2.2 | 权限授权弹窗的渲染依赖 |
| `grim` `slurp` `wl-copy` `jq` | — | 截图链路 |
| `hyprpicker` | — | 取色 |
| `brightnessctl` | — | 亮度 |
| `playerctl` | — | 媒体键 |
| `pavucontrol` | 6.2 | 混音器（waybar 音量图标点击目标） |

音频服务（用户级）：

```
pipewire.socket          active / enabled
pipewire-pulse.socket    active / enabled
wireplumber.service      active / enabled
pipewire.service         由 socket 按需激活，不需要 enable
pipewire-pulse.service   同上
```

---

## 6. 子系统说明

### 6.1 截图

`scripts/shot.sh area|full|window`：

- 产物存 `~/Pictures/Screenshots/日期_时间.png`，同时 `wl-copy` 进剪贴板，再弹一条
  `hyprctl notify` 通知。
- `area` 用 `slurp` 选框，Esc / 右键取消时 slurp 返回非零 → 脚本静默退出（不会误报失败）。
- `window` 先读 `hyprctl -j activewindow` 的 `at` / `size`；**焦点在 layer surface 或
  弹出层上时 `activewindow` 返回空对象**，此时回退到 `clients` 里
  `focusHistoryID == 0 && mapped && !hidden` 的窗口。没有这个回退，点开右键菜单再按
  截图键就会失败。

### 6.2 取色

`SUPER + C` → `scripts/pick-color.sh` → `hyprpicker -a -f hex`（`-a` 直接把结果写进
剪贴板），再从剪贴板读回来用 `hyprctl notify` 提示色值。

不用 hyprpicker 的 stdout，也不依赖 `notify-send` —— 本机没有通知守护进程，
Hyprland 0.57 内置的 `hyprctl notify` 是现成可用的。

### 6.3 音量 / 亮度 OSD

- 所有音量/亮度键都走 `swayosd-client`，它既执行动作又弹 OSD 气泡。
  音量最终仍落在 PipeWire 上，`wpctl` / `pavucontrol` 看到的数值一致。
- 样式：`~/.config/swayosd/style.css`（深色胶囊，配色对齐 waybar）。
- autostart：`swayosd-server --top-margin 0.88 -d 1200`（显示 1.2 秒，位置上移）。
- 日志里的 `GtkGizmo ... reported min width -2` 是 swayosd 0.3.2 + GTK4 的固有噪音，
  系统默认样式同样会出现，可以忽略。

### 6.4 锁屏与空闲管理

`hyprlock.conf`：

- `background.path = screenshot`（锁屏时截取当前桌面再模糊），换壁纸后锁屏自动跟随。
  取不到截图时退回 `color` 纯色底。
- 前置依赖：权限系统里必须放行 `hyprlock` 的 `screencopy`，见 6.6。

`hypridle.conf`（时间线：150s 调光 → 180s 关键盘背光 → 300s 锁屏 → 330s 关屏 → 1800s 挂起）：

- **锁屏一律直接调 `hyprlock`，不用 `loginctl lock-session`**，原因见 7.5。
- `brightnessctl` 用百分比而非绝对值，原因见 7.5。

### 6.5 屏幕共享

`xdg-desktop-portal-hyprland` 提供 ScreenCast / Screenshot / GlobalShortcuts /
InputCapture 接口，`FileChooser` 仍由 `xdg-desktop-portal-gtk` 提供。

**装完或升级后必须重启 portal，否则 DBus 激活的还是旧后端**：

```bash
systemctl --user restart xdg-desktop-portal.service
```

`RemoteDesktop` 接口不存在是正常现象（Hyprland 后端不实现输入注入），不影响共享屏幕。

### 6.6 权限系统（0.57 新特性）

`hyprland.lua` 里 `ecosystem.enforce_permissions = true`，按二进制路径授权：

| 类型 | 策略 |
|---|---|
| `screencopy` | 放行 grim、hyprpicker、hyprlock、portal 后端、share-picker；其余 `ask`（弹窗） |
| `cursorpos` | 放行 hyprpicker（否则取色会卡在无人应答的弹窗上） |
| `plugin` | 放行 hyprpm；**拒绝 hyprctl**（防 `hyprctl plugin load /tmp/x.so` 注入） |

`binary` 支持正则（`/usr/(bin|local/bin)/grim` 已验证可用）。

**关键陷阱**：把开关从 `false` 改成 `true` 的那一次加载里，`hl.permission` 注册的规则
会被丢弃，只剩默认 `ask` —— 表现为 `grim` 卡住不返回（8 秒超时 rc=124，也没有弹窗），
截图链路当场断掉。**再 reload 一次立刻正常**。

因为开机正好就是「开关刚被打开」的那一次加载，`hyprland.lua` 的 autostart 末尾加了兜底：

```lua
hl.exec_cmd("sh -c 'sleep 2; hyprctl reload >/dev/null 2>&1'")
```

`hyprctl reload` 不会重新触发 `hyprland.start`，已验证 waybar / hypridle / swayosd-server
的 pid 在多次 reload 后不变，不会拉起重复进程。上游修好后可删掉这一行。

---

## 7. 排障笔记（今天踩过的坑）

这一节是本文档最有价值的部分。每一条都是「现象 → 原因 → 处理」。

### 7.1 改了 `hyprland.conf` 完全没反应

**现象**：conf 里写 `gaps_out = 10`，实际 `hyprctl getoption general:gaps_out` 是 20。

**原因**：0.57 下 `hyprland.lua` 优先，只要它存在，`hyprland.conf` **完全不被读取**。

**处理**：所有配置写 Lua。判断依据：

```bash
hyprctl -j getoption general:gaps_out    # 和配置文件逐个比对
```

### 7.2 单按 `l` 就锁屏

**现象**：配了 `SUPER + CTRL + L` 锁屏，结果任意输入框里按 `l` 都锁屏。

**原因**：`ignore_mods` 的语义是**跳过修饰键校验**，不是「忽略多余的修饰键」。
加了它之后 modmask 完全不参与比较，裸键也会命中。

**处理**：涉及修饰键的普通绑定一律不加 `ignore_mods`。

**注意**：`hyprctl -j binds` 的 `catch_all` 字段**验证不了这件事** —— 加不加都显示
`false`。只能靠实际按键或看配置文件。

### 7.3 点面板上的工作区序号没反应

**现象**：`SUPER+1..0` 正常，鼠标点 waybar 上的工作区无效。

**原因**：旧版 waybar 的 `hyprland/workspaces` 模块硬编码向 socket 发
`dispatch workspace <id>`，而 0.57 把收到的 dispatch 串当 Lua 求值 →
`hl.dispatch(workspace 4)` 语法错误 → 点击被丢弃。
上游修复 PR #5013 只进了 master，**没有任何正式版包含它**。

**处理**：安装 `waybar-git`（已装）。新版会打印
`Hyprland IPC: detected Lua-based dispatch protocol` 并自动切换协议，
`move-to-monitor` 也会翻译成 `hl.dsp.focus({ workspace = "N", on_current_monitor = true })`。

临时兼容方案（已废弃，脚本备份在 `~/.local/bin/.bak/`）是在 `~/.local/bin/hyprctl`
放一个翻译脚本，并给 waybar 前置 PATH。**注意 Hyprland 会话自身的 PATH 不含
`~/.local/bin`**，所以那种方案必须显式塞 PATH 才生效。

### 7.4 `SUPER+F9/F10/F11` 没反应

**现象**：键位在 `hyprctl binds` 里注册正常，按下去毫无反应。

**原因**：绑定的命令 `wpctl` **不存在** —— 它属于 `wireplumber` 包，而系统只装了
`pipewire` 本体，没有 wireplumber / pipewire-pulse / pipewire-audio。整个音频栈缺一半，
pipewire 里只有 `Dummy-Driver`，没有任何真实声卡。

**处理**：装齐 `wireplumber pipewire-pulse pipewire-audio pipewire-alsa`，然后
`systemctl --user enable --now wireplumber.service pipewire-pulse.socket`。

**方法论**：这类「按了没反应」先查命令是否存在，再看绑定：

```bash
command -v wpctl                       # 不存在 → 问题不在 Hyprland
hyprctl -j binds | grep -i wpctl
```

### 7.5 `hypridle` 到点了但屏幕毫无反应

**现象**：时间到了不锁屏、不关屏。

**原因**：官方样例用 `loginctl lock-session`，但 Hyprland 0.57 二进制里
**完全没有 `org.freedesktop.login1` 相关符号**（`strings /usr/bin/Hyprland | grep -ci login1`
结果为 0），logind 发出的 Lock 信号不会启动 hyprlock。

**处理**：全部改成显式调用：

```conf
lock_cmd        = pidof hyprlock || hyprlock
before_sleep_cmd = pidof hyprlock || hyprlock --immediate-render --grace 0
```

同一类坑：样例里的 `brightnessctl -s set 10` 是**绝对值**，而 `amdgpu_bl2` 的 max 是
65535，写死 10 等于黑屏。必须用 `set 10%`。

### 7.6 开启权限系统后 `grim` 直接卡死

见 6.6，核心是「开关从 false 打开的那一次加载会丢规则，需要再 reload 一次」，
已在 autostart 里做兜底。

### 7.7 一些 API 层面的坑

- **`hyprctl getoption` 不暴露 per-device 选项**：`device[...]:sensitivity` 一律返回
  `no such option`，单设备配置只能靠手感验证。
- **`hyprctl -j binds` 的 `arg` 在 Lua 模式下是不透明索引**（如 `"143"`），
  不是命令字符串，不能用 grep arg 的方式核对绑定内容 —— 只能看配置文件本身。
- **0.57 删除了旧式 dispatcher**：`resizeactive`、`togglefloating` 等在二进制里已经
  搜不到，必须用 `hl.dsp.*`。例如：
  - `hyprctl dispatch resizeactive exact 50% 100%` → 脚本里读显示器尺寸后
    `hl.dsp.window.resize({ x = 宽*0.5, y = 高 })`
- **`hyprctl keyword` 在 0.57 同样废了**：执行只返回 `unknown request`，退出码还是 0
  —— 典型的静默失败。脚本里要动态改配置项，改用 `hyprctl eval '<lua>'`：
  `hyprctl eval 'hl.monitor({ output = "eDP-1", disabled = true })'`。
  反过来重新启用时**必须显式写 `disabled = false`**，只给 mode/position 时已有的
  `disabled = true` 会继续生效，屏幕回不来（实测）。
- **`swayosd-client` 是异步的**：它只负责给 server 发消息就返回。连续测试时必须加
  0.5~1 秒延迟，否则每一步读到的都是上一步的值，会误判成「没生效」。
- **0.57 没有内置的 overview / expo**，想要只能装 `hyprexpo` 插件。
- **调试入口**：`hyprctl repl '<lua 表达式>'` 可直接在运行中的实例里求值，例如
  `hyprctl repl 'return os.getenv("PATH")'`。

### 7.8 本机沙箱限制（仅影响自动化脚本）

如果用受限环境操作这套配置，注意：

- `uid 0` 实际映射到宿主 `uid 1000`，`/usr`、`/var/lib/pacman` 不可写，`sudo` 失败
  → **装包必须由本人在终端执行**。
- 与宿主**不共享** `/tmp` → 脚本和输出都要放在 `~/` 下。
- 需要以真实用户身份跑命令时，用 Hyprland 自己转发：

```bash
hyprctl dispatch 'hl.dsp.exec_cmd("sh ~/some-script.sh")'
```

- 沙箱里读不到 `systemctl --user` 的 DBUS；需要时在脚本里补
  `export DBUS_SESSION_BUS_ADDRESS=unix:path=/run/user/1000/bus`。

---

## 8. 已知遗留 / 待办

| 项 | 说明 |
|---|---|
| 工作区 11-14 无归属 | `rules.lua` 里已写好注释掉的 4 行，两块屏都在时会跟着焦点跑，需要时取消注释 |
| waybar 没有模糊 | 已开 blur，可加 `hl.layer_rule({ name="blur-waybar", match={ namespace="waybar" }, blur=true, ignore_alpha=0.5 })` |
| `SUPER + J` 的 togglesplit 未启用 | `J` 已被 `movefocus d` 占用，需要时换键（如 `SUPER+O`） |
| `~/.config/hypr` 不是 git 仓库 | 目前靠 `*.bak-<时间戳>` 手工备份，建议 `git init` 做版本控制 |
| autostart 的兜底 reload | 权限系统上游修好后可以删 |
| `README2.md` | 早期笔记，hyprpanel / hyprpaper 时代的写法，与现状不符，可择机清理 |

---

## 9. 备份与回滚

- 每次大改前的备份：`hyprland.lua.bak-<YYYYmmdd-HHMMSS>`（当前有
  `hyprland.lua.bak-20261102-115449`，即拆分模块前的单文件版本）。
- `waybar/style.css.bak-*`、`hyprlock` 相关样式同目录亦有备份。
- **想退回 conf 版本**：删掉或改名 `hyprland.lua` 即可，Hyprland 会重新加载
  `hyprland.conf`。注意那份 conf 是迁移前的状态，不含今天新增的截图、OSD、权限等功能。
- **想临时停用某项功能**：优先注释对应的 `hl.bind` / `hl.window_rule` 后 reload，
  不需要动包。
