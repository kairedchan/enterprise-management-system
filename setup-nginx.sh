#!/bin/bash

echo "🌐 Nginx 安装和配置脚本"
echo "此脚本将帮助您安装和配置 Nginx 来部署企业管理系统"
echo ""

# 检查是否为 root 用户
if [ "$EUID" -ne 0 ]; then 
    echo "⚠️  请使用 sudo 运行此脚本:"
    echo "  sudo ./setup-nginx.sh"
    exit 1
fi

echo "1️⃣  安装 Nginx..."
apt-get update
apt-get install -y nginx

echo ""
echo "2️⃣  检查 Nginx 状态..."
systemctl status nginx --no-pager | head -10

echo ""
echo "3️⃣  构建项目..."
cd "$(dirname "$0")"
if [ ! -d "dist" ]; then
    echo "📦 构建项目..."
    npm run build
else
    echo "✅ dist 目录已存在"
fi

echo ""
echo "4️⃣  创建 Nginx 配置..."
NGINX_CONFIG="/etc/nginx/sites-available/enterprise-management"
cat > "$NGINX_CONFIG" << EOF
# 企业管理系统 - 端口 16321
server {
    listen 16321;
    server_name localhost;
    
    root $(pwd)/dist;
    index index.html;
    
    location / {
        try_files \$uri \$uri/ /index.html;
    }
    
    # 静态文件缓存
    location ~* \.(js|css|png|jpg|jpeg|gif|ico|svg)$ {
        expires 1y;
        add_header Cache-Control "public, immutable";
    }
}
EOF

echo "✅ Nginx 配置已创建: $NGINX_CONFIG"

echo ""
echo "5️⃣  启用站点..."
ln -sf "$NGINX_CONFIG" /etc/nginx/sites-enabled/
nginx -t

echo ""
echo "6️⃣  重启 Nginx..."
systemctl restart nginx

echo ""
echo "✅ Nginx 配置完成！"
echo ""
echo "📊 部署信息:"
echo "  项目路径: $(pwd)"
echo "  Nginx 配置: $NGINX_CONFIG"
echo "  访问地址: http://localhost:16321"
echo "  备用地址: http://$(hostname -I | awk '{print $1}'):16321"
echo ""
echo "🔧 管理命令:"
echo "  重启 Nginx: sudo systemctl restart nginx"
echo "  查看日志: sudo tail -f /var/log/nginx/error.log"
echo "  查看访问: sudo tail -f /var/log/nginx/access.log"
echo ""
echo "⚠️  防火墙设置:"
echo "  如果无法访问，请确保端口 16321 已开放:"
echo "  sudo ufw allow 16321/tcp"
echo "  sudo ufw reload"