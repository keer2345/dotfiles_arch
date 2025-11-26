#!/bin/bash

# 设置图片目录
PICTURES_DIR="$HOME/Pictures/.wallpaper"
BACKUP_DIR="$PICTURES_DIR/bak"

# 创建备份目录
# mkdir -p "$BACKUP_DIR"

# 切换到图片目录
cd "$PICTURES_DIR" || exit 1

# 获取当前时间戳
CURRENT_TIMESTAMP=$(date +%s)
echo "=== 执行时间: $(date) ==="
echo "当前时间戳: $CURRENT_TIMESTAMP"

# 取时间戳前四位并减一
TIMESTAMP_PREFIX=${CURRENT_TIMESTAMP:0:4}
TARGET_PREFIX=$((TIMESTAMP_PREFIX - 1))

echo "时间戳前四位: $TIMESTAMP_PREFIX"
echo "目标压缩前缀: $TARGET_PREFIX"

# 定义要查找的模式
TARGET_PATTERN="unsplash_${TARGET_PREFIX}*.jpg"

echo "查找模式: $TARGET_PATTERN"

# 检查是否存在目标模式的文件
if ls $TARGET_PATTERN 1> /dev/null 2>&1; then
    # 压缩文件名
    ARCHIVE_NAME="bak${TARGET_PREFIX}.tar"
    ARCHIVE_PATH="$BACKUP_DIR/$ARCHIVE_NAME"
    
    echo "找到匹配文件，开始压缩..."
    
    # 创建压缩包
    tar -zcf "$ARCHIVE_PATH" $TARGET_PATTERN
    
    # 检查压缩是否成功
    if [ $? -eq 0 ]; then
        echo "成功压缩文件: $ARCHIVE_PATH"
        
        # 统计压缩的文件数量和大小
        FILE_COUNT=$(ls $TARGET_PATTERN | wc -l)
        ARCHIVE_SIZE=$(du -h "$ARCHIVE_PATH" | cut -f1)
        
        echo "压缩了 $FILE_COUNT 个文件，压缩包大小: $ARCHIVE_SIZE"
        
        # 删除原文件
        echo "删除原文件: $TARGET_PATTERN"
        rm -f $TARGET_PATTERN
        
        echo "处理完成"
    else
        echo "压缩失败，保留原文件"
        exit 1
    fi
else
    echo "未找到 $TARGET_PATTERN 文件，跳过本次处理"
fi

echo ""
echo ""
echo ""
