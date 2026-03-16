#!/bin/bash

# 企业管理系统部署脚本
# 作者: AI Assistant
# 创建日期: 2024-03-16

set -e

echo "🚀 开始部署企业管理系统..."

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}📦 项目信息${NC}"
echo "项目名称: 企业管理系统前端"
echo "技术栈: Vue 3 + TypeScript + Element Plus"
echo "构建工具: Vite"
echo ""

# 1. 检查依赖
echo -e "${BLUE}🔍 检查系统依赖${NC}"
if ! command -v node &> /dev/null; then
    echo -e "${RED}❌ Node.js 未安装${NC}"
    exit 1
fi
echo -e "${GREEN}✅ Node.js 已安装 ($(node --version))${NC}"

if ! command -v npm &> /dev/null; then
    echo -e "${RED}❌ npm 未安装${NC}"
    exit 1
fi
echo -e "${GREEN}✅ npm 已安装 ($(npm --version))${NC}"

# 2. 安装项目依赖
echo -e "\n${BLUE}📥 安装项目依赖${NC}"
npm install
echo -e "${GREEN}✅ 依赖安装完成${NC}"

# 3. 构建项目
echo -e "\n${BLUE}🔨 构建项目${NC}"
npm run build
echo -e "${GREEN}✅ 项目构建完成${NC}"

# 4. 检查构建结果
echo -e "\n${BLUE}📊 检查构建结果${NC}"
if [ -d "dist" ]; then
    echo -e "${GREEN}✅ dist 目录已生成${NC}"
    echo "构建文件统计:"
    find dist -type f | wc -l | xargs echo "  文件数量:"
    du -sh dist | awk '{print "  大小: "$1}'
else
    echo -e "${RED}❌ dist 目录未生成，构建失败${NC}"
    exit 1
fi

# 5. GitHub 部署指南
echo -e "\n${BLUE}🐙 GitHub 部署指南${NC}"
echo "请按照以下步骤将项目推送到 GitHub:"
echo ""
echo "1. 访问 https://github.com/new 创建新仓库"
echo "2. 仓库名称: enterprise-management-system"
echo "3. 描述: Vue3 + ElementPlus + TypeScript 企业管理系统"
echo "4. 选择公开或私有仓库"
echo "5. 不添加 README.md（项目已有）"
echo ""
echo "创建后，运行以下命令:"
echo ""
echo "git remote add origin https://github.com/你的用户名/enterprise-management-system.git"
echo "git branch -M main"
echo "git push -u origin main"
echo ""

# 6. Nginx 部署配置
echo -e "${BLUE}🌐 Nginx 部署配置${NC}"
echo "请将以下配置添加到 Nginx 配置文件中 (/etc/nginx/sites-available/default):"
echo ""
cat << 'EOF'
server {
    listen 16321;
    server_name localhost;
    
    root /path/to/your/project/dist;
    index index.html;
    
    location / {
        try_files $uri $uri/ /index.html;
    }
    
    # 启用 gzip 压缩
    gzip on;
    gzip_types text/plain text/css application/json application/javascript text/xml application/xml application/xml+rss text/javascript;
    
    # 静态文件缓存
    location ~* \.(jpg|jpeg|png|gif|ico|css|js)$ {
        expires 1y;
        add_header Cache-Control "public, immutable";
    }
}
EOF
echo ""

# 7. Docker 部署选项
echo -e "${BLUE}🐳 Docker 部署选项${NC}"
echo "创建 Dockerfile:"
cat << 'EOF'
FROM nginx:alpine
COPY dist /usr/share/nginx/html
COPY nginx.conf /etc/nginx/conf.d/default.conf
EXPOSE 16321
CMD ["nginx", "-g", "daemon off;"]
EOF
echo ""
echo "创建 nginx.conf:"
cat << 'EOF'
server {
    listen 16321;
    server_name localhost;
    
    root /usr/share/nginx/html;
    index index.html;
    
    location / {
        try_files $uri $uri/ /index.html;
    }
    
    gzip on;
    gzip_types text/plain text/css application/json application/javascript text/xml application/xml application/xml+rss text/javascript;
}
EOF
echo ""
echo "构建和运行 Docker 镜像:"
echo "docker build -t enterprise-management ."
echo "docker run -d -p 16321:16321 --name enterprise-app enterprise-management"

# 8. 本地开发运行
echo -e "\n${BLUE}💻 本地开发运行${NC}"
echo "启动开发服务器:"
echo "npm run dev"
echo ""
echo "访问: http://localhost:5173"
echo ""
echo "生产环境预览:"
echo "npm run preview"
echo ""
echo "访问: http://localhost:4173"

echo -e "\n${GREEN}🎉 部署指南生成完成！${NC}"
echo ""
echo "📋 下一步操作建议:"
echo "1. 运行 npm run dev 启动开发服务器"
echo "2. 创建 GitHub 仓库并推送代码"
echo "3. 配置 Nginx 并启动服务"
echo "4. 访问 http://localhost:16321 查看部署效果"
echo ""
echo "如有问题，请参考项目 README.md 文件。"