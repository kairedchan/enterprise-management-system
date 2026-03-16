#!/bin/bash

echo "🔒 Nginx HTTPS 安装和配置脚本"
echo "此脚本将配置 Nginx 支持 HTTPS 访问企业管理系统"
echo "域名: dell.codekfc.top"
echo "端口: 16321 (HTTPS)"
echo ""

# 检查是否为 root 用户
if [ "$EUID" -ne 0 ]; then 
    echo "⚠️  请使用 sudo 运行此脚本:"
    echo "  sudo ./setup-nginx-https.sh"
    exit 1
fi

# 检查证书文件
CERT_KEY="/mnt/d/ideaProject/testMaven/nginx/cert/dell.codekfc.top.key"
CERT_PEM="/mnt/d/ideaProject/testMaven/nginx/cert/dell.codekfc.top.pem"

if [ ! -f "$CERT_KEY" ]; then
    echo "❌ 证书私钥文件不存在: $CERT_KEY"
    exit 1
fi

if [ ! -f "$CERT_PEM" ]; then
    echo "❌ 证书文件不存在: $CERT_PEM"
    exit 1
fi

echo "✅ 证书文件检查通过:"
echo "   私钥: $CERT_KEY"
echo "   证书: $CERT_PEM"
echo ""

# 检查 Nginx 是否已安装
if ! command -v nginx &> /dev/null; then
    echo "📦 安装 Nginx..."
    apt-get update
    apt-get install -y nginx
else
    echo "✅ Nginx 已安装"
fi

echo ""
echo "🔄 检查 Nginx 状态..."
systemctl status nginx --no-pager | head -5

echo ""
echo "📦 构建项目（如果需要）..."
cd "$(dirname "$0")"
if [ ! -d "dist" ]; then
    echo "正在构建项目..."
    npm run build
else
    echo "✅ dist 目录已存在"
fi

echo ""
echo "⚙️  创建 Nginx HTTPS 配置..."
NGINX_CONFIG="/etc/nginx/sites-available/enterprise-management-https"
cat > "$NGINX_CONFIG" << 'EOF'
# 企业管理系统 Nginx HTTPS 配置
# 域名: dell.codekfc.top
# HTTPS 端口: 16321

# HTTP 重定向到 HTTPS
server {
    listen 80;
    server_name dell.codekfc.top;
    return 301 https://$server_name:16321$request_uri;
}

# HTTPS 主服务器
server {
    listen 16321 ssl http2;
    server_name dell.codekfc.top;
    
    # SSL 证书
    ssl_certificate /mnt/d/ideaProject/testMaven/nginx/cert/dell.codekfc.top.pem;
    ssl_certificate_key /mnt/d/ideaProject/testMaven/nginx/cert/dell.codekfc.top.key;
    
    # SSL 配置
    ssl_protocols TLSv1.2 TLSv1.3;
    ssl_prefer_server_ciphers on;
    
    # 安全头部
    add_header Strict-Transport-Security "max-age=63072000" always;
    add_header X-Frame-Options "SAMEORIGIN" always;
    add_header X-Content-Type-Options "nosniff" always;
    add_header X-XSS-Protection "1; mode=block" always;
    
    # 项目目录
    root /mnt/d/openclaw/autoCode/my-vue-app/dist;
    index index.html;
    
    # SPA 路由
    location / {
        try_files $uri $uri/ /index.html;
    }
    
    # 静态资源缓存
    location ~* \.(js|css|png|jpg|jpeg|gif|ico|svg)$ {
        expires 1y;
        add_header Cache-Control "public, immutable";
    }
    
    # 启用 gzip
    gzip on;
    gzip_types text/plain text/css application/json application/javascript text/xml application/xml image/svg+xml;
}
EOF

echo "✅ Nginx HTTPS 配置已创建: $NGINX_CONFIG"

echo ""
echo "🔗 启用站点配置..."
ln -sf "$NGINX_CONFIG" /etc/nginx/sites-enabled/

echo ""
echo "🔍 测试 Nginx 配置..."
nginx -t

if [ $? -eq 0 ]; then
    echo ""
    echo "🔄 重启 Nginx 服务..."
    systemctl restart nginx
    
    echo ""
    echo "🎉 HTTPS 配置完成！"
    echo ""
    echo "📊 部署信息:"
    echo "   域名: dell.codekfc.top"
    echo "   HTTPS 端口: 16321"
    echo "   项目路径: $(pwd)"
    echo "   证书路径: $(dirname "$CERT_KEY")"
    echo ""
    echo "🌐 访问地址:"
    echo "   HTTPS: https://dell.codekfc.top:16321"
    echo "   HTTP (自动重定向): http://dell.codekfc.top"
    echo ""
    echo "🔧 管理命令:"
    echo "   查看证书: openssl x509 -in $CERT_PEM -text -noout"
    echo "   测试 SSL: openssl s_client -connect dell.codekfc.top:16321"
    echo "   查看日志: sudo tail -f /var/log/nginx/error.log"
    echo ""
    echo "⚠️  防火墙设置:"
    echo "   确保端口已开放:"
    echo "   sudo ufw allow 80/tcp"
    echo "   sudo ufw allow 16321/tcp"
    echo "   sudo ufw reload"
else
    echo "❌ Nginx 配置测试失败，请检查配置"
    exit 1
fi