#!/bin/bash

# 刷新最新一张图片作为壁纸

# 进入目录
cd ~/Pictures/.wallpaper
# 获取最新的文件名
FILE_NAME=$(find . -maxdepth 1 -type f -printf '%T@ %p\n' | sort -n | tail -1 | cut -f2- -d" ")

# nitrogen --set-zoom-fill --save "$FILE_NAME" 2>/dev/null
feh --bg-fill "$FILE_NAME" 2>/dev/null

