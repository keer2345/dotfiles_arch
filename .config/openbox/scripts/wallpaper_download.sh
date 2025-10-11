#!/bin/bash

# 配置变量
ACCESS_KEY="Y_Z0d-7o3tx8ig7svcMTSo3Gwqbo5xahYXrEeOyvBzQ"  # 务必替换成你的Key！
WALLPAPER_DIR="$HOME/Pictures/.wallpaper"
# 可以从多个主题中选择：nature, space, texture, abstract, gradient...
QUERY="nature"

# 创建目录（如果不存在的话）
mkdir -p "$WALLPAPER_DIR"

# 图片API URL
# 这个URL会返回一张随机的高分辨率nature图片
IMAGE_URL="https://api.unsplash.com/photos/random?client_id=${ACCESS_KEY}&query=${QUERY}&orientation=landscape&w=1920"

echo $IMAGE_URL

# 获取图片的真实下载地址
# Unsplash的API返回JSON，我们用 `grep` 和 `sed` 来提取 `urls.full` 字段
DOWNLOAD_LINK=$(curl -s "$IMAGE_URL" | grep -o '"full":"[^"]*"' | sed 's/"full":"//;s/"//')

echo $DOWNLOAD_LINK

# 生成一个唯一的文件名（例如使用Unix时间戳）
FILENAME="unsplash_$(date +%s).jpg"
SAVE_PATH="${WALLPAPER_DIR}/${FILENAME}"

# 下载图片
echo "Downloading new wallpaper from Unsplash..."

curl -s -o "$SAVE_PATH" "$DOWNLOAD_LINK"


# 检查下载是否成功
if [ -f "$SAVE_PATH" ]; then
    echo "Wallpaper saved to: $SAVE_PATH"

    # 调用Nitrogen设置新壁纸
    # nitrogen --set-zoom-fill --save "$SAVE_PATH" 2>/dev/null
    
    # 调用feh
    feh --bg-fill "$SAVE_PATH" 2>/dev/null
else
    echo "Download failed."
    exit 1
fi
