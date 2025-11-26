#!/bin/bash
# ~/.config/hypr/scripts/random-wallpaper.sh

WALLPAPER_DIR="$HOME/Pictures/.wallpaper"
CONFIG_FILE="$HOME/.config/hypr/hyprpaper.conf"

# 获取所有 jpg 文件
get_wallpapers() {
    find "$WALLPAPER_DIR" -name "*.jpg" -type f
}

# 随机选择壁纸文件
random_file() {
    local files=($(get_wallpapers))
    if [ ${#files[@]} -eq 0 ]; then
        echo "错误: 在 $WALLPAPER_DIR 中未找到 jpg 文件" >&2
        exit 1
    fi
    echo "${files[RANDOM % ${#files[@]}]}"
}

# 设置随机壁纸
set_random_wallpaper() {
    echo "正在设置随机壁纸..."
    
    # 为每个显示器选择壁纸（可以相同或不同）
    local wallpaper1=$(random_file)
    local wallpaper2=$(random_file)
    
    # 清空现有配置并创建新的
    cat > "$CONFIG_FILE" << EOF
# 预加载壁纸
preload = $wallpaper1
preload = $wallpaper2

# 设置显示器壁纸
wallpaper = eDP-1,$wallpaper1
wallpaper = DP-1,$wallpaper2
EOF
    
    # 重启 hyprpaper 应用新配置
    pkill hyprpaper
    hyprpaper &
    
    echo "壁纸设置完成:"
    echo "eDP-1: $(basename "$wallpaper1")"
    echo "DP-1: $(basename "$wallpaper2")"
}

# 主程序
case "${1:-}" in
    "once")
        set_random_wallpaper
        ;;
    "daemon")
        set_random_wallpaper
        while true; do
            sleep 3600  # 等待1小时
            set_random_wallpaper
        done
        ;;
    *)
        echo "用法: $0 [once|daemon]"
        echo "  once   - 设置一次随机壁纸"
        echo "  daemon - 设置壁纸并每小时自动更换"
        ;;
esac
