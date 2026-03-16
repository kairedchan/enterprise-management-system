#!/bin/bash

echo "🚀 启动企业管理系统开发服务器..."

# 检查 node_modules
if [ ! -d "node_modules" ]; then
    echo "📥 安装依赖..."
    npm install
fi

echo "🔧 启动开发服务器..."
npm run dev

echo ""
echo "✅ 开发服务器已启动！"
echo "🌐 请在浏览器中访问: http://localhost:5173"
echo ""
echo "📝 开发说明:"
echo "  1. 代码修改后会自动热重载"
echo "  2. 按 Ctrl+C 停止服务器"
echo "  3. 运行 npm run build 进行生产构建"
echo "  4. 运行 npm run preview 预览构建结果"