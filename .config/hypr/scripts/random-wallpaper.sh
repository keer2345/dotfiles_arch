#!/bin/bash
# ~/.config/hypr/scripts/random-wallpaper.sh

WALLPAPER_DIR="$HOME/Pictures/.wallpaper"
CONFIG_FILE="$HOME/.config/hypr/hyprpaper.conf"
LOG_FILE="$HOME/.local/share/hyprpaper-wallpaper.log"

# 创建日志目录
mkdir -p "$(dirname "$LOG_FILE")"

# 等待 Hyprland 就绪
wait_for_hyprland() {
    local max_attempts=30
    local attempt=0
    
    while [ $attempt -lt $max_attempts ]; do
        if hyprctl monitors >/dev/null 2>&1; then
            log "Hyprland 已就绪"
            return 0
        fi
        log "等待 Hyprland 启动... ($((attempt+1))/$max_attempts)"
        sleep 2
        ((attempt++))
    done
    
    log "错误: 等待 Hyprland 超时"
    return 1
}

# 日志函数
log() {
    echo "$(date '+%Y-%m-%d %H:%M:%S'): $1" >> "$LOG_FILE"
    echo "$1"  # 同时输出到控制台
}

# 获取所有壁纸文件
get_wallpapers() {
    find "$WALLPAPER_DIR" -name "*.jpg" -type f
}

# 随机选择文件
random_file() {
    local files=($(get_wallpapers))
    if [ ${#files[@]} -eq 0 ]; then
        log "错误: 在 $WALLPAPER_DIR 中未找到 jpg 文件"
        return 1
    fi
    echo "${files[RANDOM % ${#files[@]}]}"
}

# 正确重启 hyprpaper
restart_hyprpaper() {
    log "重启 hyprpaper..."
    
    # 杀死现有 hyprpaper 进程
    pkill -f hyprpaper
    
    # 等待进程完全结束
    sleep 1
    
    # 启动新的 hyprpaper 进程
    hyprpaper &
    
    # 等待 hyprpaper 启动
    sleep 2
    
    log "hyprpaper 重启完成"
}

# 设置随机壁纸
set_random_wallpaper() {
    log "开始设置随机壁纸..."
    
    local wallpaper1=$(random_file) || return 1
    local wallpaper2=$(random_file) || return 1
    
    log "选择壁纸 - eDP-1: $(basename "$wallpaper1")"
    log "选择壁纸 - DP-1: $(basename "$wallpaper2")"
    
    # 创建配置文件
    cat > "$CONFIG_FILE" << EOF
# 自动生成的壁纸配置 - $(date)
preload = $wallpaper1
preload = $wallpaper2
wallpaper = eDP-1,$wallpaper1
wallpaper = DP-1,$wallpaper2
EOF
    
    # 重启 hyprpaper 以应用新配置
    restart_hyprpaper

    sleep 1

    # 使用 hyprctl 直接设置壁纸（更可靠）
    if hyprctl hyprpaper wallpaper "eDP-1,$wallpaper1" >> "$LOG_FILE" 2>&1; then
        log "成功设置 eDP-1 壁纸"
    else
        log "警告: hyprctl 设置 eDP-1 失败"
    fi
    
    if hyprctl hyprpaper wallpaper "DP-1,$wallpaper2" >> "$LOG_FILE" 2>&1; then
        log "成功设置 DP-1 壁纸"
    else
        log "警告: hyprctl 设置 DP-1 失败"
    fi
    
    log "壁纸设置完成"
}

# 定时器模式 - 每小时切换
timer_mode() {
    wait_for_hyprland || return 1
    
    # 立即设置一次壁纸
    set_random_wallpaper
    
    # 计算到下一个整点的时间
    local current_minute=$(date +%M)
    local current_second=$(date +%S)
    local minutes_to_wait=$((60 - current_minute))
    local seconds_to_wait=$((minutes_to_wait * 60 - current_second))
    
    log "下一次壁纸切换在 $minutes_to_wait 分钟后"
    sleep $seconds_to_wait
    
    # 主循环 - 每小时执行一次
    while true; do
        set_random_wallpaper
        log "等待下一小时..."
        sleep 3600  # 等待1小时
    done
}

# 单次模式
once_mode() {
    wait_for_hyprland || return 1
    set_random_wallpaper
}

# 检查状态
status_mode() {
    echo "=== 壁纸状态 ==="
    echo "当前配置文件: $CONFIG_FILE"
    if [ -f "$CONFIG_FILE" ]; then
        echo "配置内容:"
        cat "$CONFIG_FILE"
    else
        echo "未找到配置文件"
    fi
    
    echo -e "\n=== 进程状态 ==="
    if pgrep -x hyprpaper > /dev/null; then
        echo "hyprpaper 正在运行 (PID: $(pgrep -x hyprpaper))"
    else
        echo "hyprpaper 未运行"
    fi
    
    echo -e "\n=== 壁纸文件 ==="
    local wallpapers=($(get_wallpapers))
    echo "找到 ${#wallpapers[@]} 个壁纸文件"
}

# 主程序
case "${1:-}" in
    "once")
        log "启动单次模式"
        once_mode
        ;;
    "timer")
        log "启动定时器模式"
        timer_mode
        ;;
    "status")
        status_mode
        ;;
    "restart")
        log "手动重启 hyprpaper"
        restart_hyprpaper
        ;;
    *)
        echo "用法: $0 [once|timer|status|restart]"
        echo "  once    - 设置一次随机壁纸"
        echo "  timer   - 设置壁纸并每小时自动更换"
        echo "  status  - 显示当前壁纸状态"
        echo "  restart - 仅重启 hyprpaper 进程"
        exit 1
        ;;
esac
