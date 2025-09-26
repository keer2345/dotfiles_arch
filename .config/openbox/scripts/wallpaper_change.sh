#!/bin/bash

cd ~/.config/openbox/scripts

# 运行下载脚本
source wallpaper_download.sh

# 配置变量
WALLPAPER_DIR="$HOME/Pictures/.wallpaper"
MAX_FILES=500  # 设置最大壁纸保存数量


# （可选）清理旧壁纸，只保留最新的 MAX_FILES 张
cd "$WALLPAPER_DIR" || exit
# 按修改时间排序，删除最老的文件，直到文件数等于MAX_FILES
while [ $(ls -1 | wc -l) -gt $MAX_FILES ]; do
    oldest_file=$(ls -t | tail -1)
    echo "Removing old wallpaper: $oldest_file"
    rm -- "$oldest_file"
done

echo "Wallpaper rotation and cleanup complete."
