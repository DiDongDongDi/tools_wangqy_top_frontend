#!/bin/bash

# 设置错误时退出
set -e

echo "开始打包 dist 目录..."

# 进入脚本所在目录的上一级目录
cd "$(dirname "$0")/.."


# 检查是否存在 dist 目录
if [ -d "dist" ]; then
    echo "发现已存在的 dist 目录，正在删除..."
    rm -rf dist
fi

# 构建项目
echo "正在构建项目..."
/Users/kodyqywang/.nvm/versions/node/v23.11.0/bin/npm run build

# 检查构建是否成功
if [ ! -d "dist" ]; then
    echo "错误：构建失败，dist 目录未生成"
    exit 1
fi

# 创建压缩包
echo "正在创建压缩包..."
zip_name="dist.zip"

# 进入 dist 目录并压缩
cd dist
zip -r "../${zip_name}" .
cd ..

echo "打包完成！"
echo "压缩包名称: ${zip_name}"
echo "压缩包大小: $(du -h "${zip_name}" | cut -f1)"

# 可选：显示压缩包内容
echo "压缩包内容:"
unzip -l "${zip_name}" | head -20
