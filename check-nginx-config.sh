#!/bin/bash

echo "🔍 Nginx 配置检查脚本"
echo "===================="
echo ""

# 颜色定义
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo "1. 检查 sites-enabled/ 目录配置:"
ls -la /etc/nginx/sites-enabled/
echo ""

echo "2. 检查端口冲突:"
echo "   监听 16321 端口的配置:"
sudo nginx -T 2>/dev/null | grep -B5 -A5 "listen.*16321" | grep -E "(server_name|listen|ssl_certificate)" | sed 's/^/    /'
echo ""

echo "3. 检查其他可能冲突的端口:"
PORTS_TO_CHECK="80 443 16321"
for port in $PORTS_TO_CHECK; do
    COUNT=$(sudo nginx -T 2>/dev/null | grep -c "listen.*$port")
    if [ "$COUNT" -gt 1 ]; then
        echo -e "   ${RED}⚠️  端口 $port 有 $COUNT 个配置冲突${NC}"
        sudo nginx -T 2>/dev/null | grep -B2 -A2 "listen.*$port" | sed 's/^/      /'
    else
        echo -e "   ${GREEN}✅ 端口 $port 配置正常${NC}"
    fi
done
echo ""

echo "4. 检查配置文件语法:"
if sudo nginx -t 2>/dev/null; then
    echo -e "   ${GREEN}✅ Nginx 配置语法正确${NC}"
else
    echo -e "   ${RED}❌ Nginx 配置有语法错误${NC}"
    sudo nginx -t 2>&1 | tail -5 | sed 's/^/      /'
fi
echo ""

echo "5. 检查当前生效配置:"
echo "   有效 server 块数量: $(sudo nginx -T 2>/dev/null | grep -c "^server {")"
echo ""

echo "6. 配置文件清理建议:"
ENABLED_FILES=$(ls /etc/nginx/sites-enabled/ 2>/dev/null | wc -l)
AVAILABLE_FILES=$(ls /etc/nginx/sites-available/ 2>/dev/null | wc -l)

if [ "$ENABLED_FILES" -gt 3 ]; then
    echo -e "   ${YELLOW}⚠️  sites-enabled/ 中有 $ENABLED_FILES 个文件，建议清理${NC}"
    echo "   当前文件:"
    ls -1 /etc/nginx/sites-enabled/ | sed 's/^/      /'
fi

echo ""
echo "7. 推荐操作:"
echo "   a. 清理冲突配置:"
echo "      sudo rm -f /etc/nginx/sites-enabled/冲突文件"
echo "   b. 重新加载配置:"
echo "      sudo nginx -s reload"
echo "   c. 重启服务:"
echo "      sudo systemctl restart nginx"
echo ""

echo "📋 配置冲突常见原因:"
echo "   1. 同一端口多个 server 块"
echo "   2. 同一域名多个配置"
echo "   3. 默认配置未禁用"
echo "   4. 临时配置未清理"
echo ""

echo "🔧 修复脚本:"
echo "   # 清理所有企业相关配置"
echo "   sudo rm -f /etc/nginx/sites-available/enterprise-* /etc/nginx/sites-enabled/enterprise-*"
echo "   # 重新创建配置"
echo "   sudo cp nginx-https.conf /etc/nginx/sites-available/enterprise-https-only"
echo "   sudo ln -sf /etc/nginx/sites-available/enterprise-https-only /etc/nginx/sites-enabled/"
echo "   sudo nginx -t && sudo systemctl restart nginx"
echo ""
echo "✅ 检查完成"