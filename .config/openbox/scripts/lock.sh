#!/bin/bash

cd ~/Pictures/.wallpaper

FILE_NAME=$(find . -maxdepth 1 -type f -printf '%T@ %p\n' | sort -n | tail -1 | cut -f2- -d" ")

magick $FILE_NAME -blur 0x5 /tmp/lock-screen.jpg
 
# 添加锁定图标
 
# 锁定屏幕
i3lock -i /tmp/lock-screen.jpg
