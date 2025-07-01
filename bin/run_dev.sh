#!/bin/bash

# 设置错误时退出
set -e

echo "启动开发环境..."

# 进入脚本所在目录的上一级目录
cd "$(dirname "$0")/.."

# 检查是否已经在运行
if pgrep -f "npm run dev" >/dev/null; then
  echo "开发环境已经在运行中"
  echo "进程信息:"
  ps aux | grep "npm run dev" | grep -v grep
  exit 0
fi

# 启动开发环境到后台
echo "正在启动开发环境到后台..."

# 加载 nvm 环境
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"                   # 加载 nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion" # 加载 nvm bash_completion

# 使用指定版本的 Node.js
nvm use 23.11.0
nohup npm run dev >dev.log 2>&1 &

# 获取进程ID
DEV_PID=$!

# 等待一下确保进程启动
sleep 2

# 检查进程是否成功启动
if kill -0 $DEV_PID 2>/dev/null; then
  echo "开发环境启动成功！"
  echo "进程ID: $DEV_PID"
  echo "日志文件: dev.log"
  echo ""
  echo "查看日志: tail -f dev.log"
  echo "停止服务: kill $DEV_PID"
else
  echo "开发环境启动失败，请检查日志文件 dev.log"
  exit 1
fi
