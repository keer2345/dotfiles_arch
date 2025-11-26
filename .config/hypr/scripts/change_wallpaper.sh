#!/bin/bash

WALLPAPER_DIR="/home/keer/Pictures/.wallpaper"
CONFIG_FILE="$HOME/.config/hyprpaper/hyprpaper.conf"
TMP_CONFIG=$(mktemp)

# 获取所有 .jpg 文件
wallpapers=($(find "$WALLPAPER_DIR" -maxdepth 1 -type f -name "*.jpg"))

if [ ${#wallpapers[@]} -eq 0 ]; then
    echo "❌ 未找到任何壁纸 .jpg 文件！"
    exit 1
fi

# 随机选一张
random_wallpaper="${wallpapers[$RANDOM % ${#wallpapers[@]}]}"
echo "🖼️ 随机选择壁纸: $random_wallpaper"

# 生成新的配置内容
{
    echo "monitor=eDP-1,wallpaper,$random_wallpaper,fill"
    echo "monitor=DP-1,wallpaper,$random_wallpaper,fill"
} > "$TMP_CONFIG"

# 替换原配置
mv "$TMP_CONFIG" "$CONFIG_FILE"

# 重启 hyprpaper 以应用新壁纸（简单有效）
pkill hyprpaper
hyprpaper &

echo "✅ 壁纸已更换为: $random_wallpaper （于 $(date)）"
