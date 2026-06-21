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
设置和管理步骤
```shell'
# 1. 使脚本可执行
chmod +x ~/.config/hypr/scripts/random-wallpaper.sh

# 2. 创建 systemd 目录（如果不存在）
mkdir -p ~/.config/systemd/user

# 3. 重新加载 systemd
systemctl --user daemon-reload

# 4. 测试脚本
~/.config/hypr/scripts/random-wallpaper.sh once

# 5. 启动服务
systemctl --user start wallpaper-changer.service

# 6. 检查状态
systemctl --user status wallpaper-changer.service

# 7. 查看实时日志
journalctl --user -u wallpaper-changer.service -f

# 8. 启用开机自启（可选）
systemctl --user enable wallpaper-changer.service
```
Hyprland Configuration:
```shell
# ~/.config/hypr/hyprland.conf

# 启动 hyprpaper
# exec-once = hyprpaper

# 启动壁纸切换服务
exec-once = systemctl --user start wallpaper-changer.service
```
管理命令
```shell
# 查看服务状态
systemctl --user status wallpaper-changer

# 停止服务
systemctl --user stop wallpaper-changer

# 重启服务
systemctl --user restart wallpaper-changer

# 查看日志
journalctl --user -u wallpaper-changer -n 20

# 实时监控日志
journalctl --user -u wallpaper-changer -f

# 手动触发壁纸切换（不停止服务）
~/.config/hypr/scripts/random-wallpaper.sh once
```
验证功能
```shell
# 检查壁纸是否每小时切换
tail -f ~/.local/share/hyprpaper-wallpaper.log

# 查看当前配置
~/.config/hypr/scripts/random-wallpaper.sh status
```
## Status bar

[hyprpanel](https://hyprpanel.com/)

```shell
yay -S ags-hyprpanel-git
```

