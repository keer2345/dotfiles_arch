# Hyprland

```shell
yay -S hyprland 
```
## 参考
- [Hyprland 安装与配置超详细教程 (Arch Linux)：含 Waybar 及一键脚本](https://forum.archlinuxcn.org/t/topic/14852)
## wallpaper
```shell
yay -S hyprpaper
```

Configuration file: `~/.config/hypr/hyprpaper.conf`

### Random Setup Wallpaper

Script: 
- `~/.config/hypr/scripts/random-wallpaper.sh`
- `~/.config/systemd/user/wallpaper-changer.service`
### Startup
Hyprland Configuration:
```shell
# ~/.config/hypr/hyprland.conf

# 启动 hyprpaper
exec-once = hyprpaper

# 启动时设置随机壁纸
exec-once = ~/.config/hypr/scripts/random-wallpaper.sh once

# 或者使用 systemd 服务（推荐）
exec-once = systemctl --user start wallpaper-changer.service
```
Startup in Systemd:
```shell
# 使脚本可执行
chmod +x ~/.config/hypr/scripts/random-wallpaper.sh

# 重新加载 systemd
systemctl --user daemon-reload

# 启用服务（可选）
systemctl --user enable wallpaper-changer.service
```
## Status bar

[hyprpanel](https://hyprpanel.com/)

```shell
yay -S ags-hyprpanel-git
```

