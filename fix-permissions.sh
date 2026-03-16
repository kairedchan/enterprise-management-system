#!/bin/bash

echo "🔧 修复权限脚本"
echo "================"
echo ""

# 需要 root 权限
if [ "$EUID" -ne 0 ]; then 
    echo "⚠️  请使用 sudo 运行此脚本:"
    echo "  sudo ./fix-permissions.sh"
    exit 1
fi

CERT_DIR="/mnt/d/ideaProject/testMaven/nginx/cert"
PROJECT_DIR="/mnt/d/openclaw/autoCode/my-vue-app"

echo "1. 修复证书文件权限..."
if [ -d "$CERT_DIR" ]; then
    # 设置目录权限
    chmod 755 "$CERT_DIR"
    
    # 设置证书文件权限
    find "$CERT_DIR" -name "*.pem" -exec chmod 644 {} \;
    find "$CERT_DIR" -name "*.key" -exec chmod 640 {} \;
    
    # 设置文件所有者
    chown -R www-data:www-data "$CERT_DIR"
    
    echo "✅ 证书权限已修复"
    echo "   目录权限: 755"
    echo "   PEM文件: 644 (www-data:www-data)"
    echo "   KEY文件: 640 (www-data:www-data)"
else
    echo "❌ 证书目录不存在: $CERT_DIR"
fi

echo ""
echo "2. 修复项目文件权限..."
if [ -d "$PROJECT_DIR/dist" ]; then
    # 设置 dist 目录权限
    chmod -R 755 "$PROJECT_DIR/dist"
    chown -R www-data:www-data "$PROJECT_DIR/dist"
    
    echo "✅ 项目文件权限已修复"
    echo "   dist目录: 755 (www-data:www-data)"
else
    echo "⚠️  dist目录不存在，可能需要先构建项目"
    echo "   运行: cd $PROJECT_DIR && npm run build"
fi

echo ""
echo "3. 修复 Nginx 日志权限..."
# 确保 Nginx 可以写入日志
chown -R www-data:www-data /var/log/nginx 2>/dev/null
chmod -R 755 /var/log/nginx 2>/dev/null

echo "✅ Nginx 日志权限已修复"

echo ""
echo "4. 重启 Nginx 服务..."
systemctl restart nginx

if systemctl is-active nginx >/dev/null 2>&1; then
    echo "✅ Nginx 重启成功"
else
    echo "❌ Nginx 重启失败"
    systemctl status nginx --no-pager | head -10
fi

echo ""
echo "5. 验证权限修复..."
echo "   证书目录:"
ls -la "$CERT_DIR/" 2>/dev/null | head -5

echo ""
echo "   Nginx 用户测试访问:"
sudo -u www-data ls -l "$CERT_DIR/" 2>/dev/null && echo "✅ Nginx 用户可以访问证书" || echo "❌ Nginx 用户无法访问证书"

echo ""
echo "📋 权限配置总结:"
echo "   1. 证书目录: 755 (www-data:www-data)"
echo "   2. PEM证书: 644 (www-data:www-data)"
echo "   3. KEY私钥: 640 (www-data:www-data)"
echo "   4. 项目文件: 755 (www-data:www-data)"
echo "   5. Nginx日志: 755 (www-data:www-data)"
echo ""
echo "🔧 后续维护:"
echo "   如果更新证书文件，运行此脚本重新设置权限"
echo "   如果更新项目文件，确保 dist/ 目录权限正确"
echo ""
echo "✅ 权限修复完成"