#!/bin/bash

# 进入目录
cd ~/Pictures/.wallpaper

action=$1

case $action in
    "latest")
        # 刷新最新一张图片作为壁纸
        # 获取最新的文件名
        FILE_NAME=$(find . -maxdepth 1 -type f -printf '%T@ %p\n' | sort -n | tail -1 | cut -f2- -d" ")
        
        # nitrogen --set-zoom-fill --save "$FILE_NAME" 2>/dev/null
        feh --bg-fill "$FILE_NAME" 2>/dev/null
        ;;
    "random")
        # 随机设置壁纸
        feh --randomize --bg-fill ./*.jpg
        ;;
    *)
        echo "Usage: $0 {latest|random}"
        exit 1
        ;;
esac




