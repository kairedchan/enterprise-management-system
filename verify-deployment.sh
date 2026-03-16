#!/bin/bash

echo "🔍 部署验证脚本"
echo "================"
echo ""

# 颜色定义
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

check_status() {
    local name="$1"
    local command="$2"
    local expected="$3"
    
    echo -n "检查 $name... "
    if eval "$command" 2>/dev/null | grep -q "$expected"; then
        echo -e "${GREEN}✅ 通过${NC}"
        return 0
    else
        echo -e "${RED}❌ 失败${NC}"
        return 1
    fi
}

echo "1. 检查 Nginx 服务状态..."
sudo systemctl is-active nginx >/dev/null 2>&1
if [ $? -eq 0 ]; then
    echo -e "${GREEN}✅ Nginx 正在运行${NC}"
else
    echo -e "${RED}❌ Nginx 未运行${NC}"
fi

echo ""
echo "2. 检查端口监听..."
if sudo netstat -tlnp 2>/dev/null | grep -q ":16321"; then
    echo -e "${GREEN}✅ 端口 16321 正在监听${NC}"
    sudo netstat -tlnp 2>/dev/null | grep ":16321"
else
    echo -e "${RED}❌ 端口 16321 未监听${NC}"
fi

echo ""
echo "3. 测试 HTTPS 访问..."
timeout 3 curl -k -I https://localhost:16321 2>/dev/null | head -1
if [ $? -eq 0 ]; then
    echo -e "${GREEN}✅ HTTPS 访问正常${NC}"
else
    echo -e "${RED}❌ HTTPS 访问失败${NC}"
fi

echo ""
echo "4. 测试 HTTP 访问（应该失败）..."
timeout 3 curl -I http://localhost:16321 2>&1 | grep -q "curl"
if [ $? -ne 0 ]; then
    echo -e "${YELLOW}⚠️  HTTP 不应该可访问${NC}"
else
    echo -e "${GREEN}✅ HTTP 访问被正确拒绝${NC}"
fi

echo ""
echo "5. 测试 SSL 证书..."
timeout 3 openssl s_client -connect localhost:16321 -servername dell.codekfc.top 2>/dev/null | grep -q "Certificate chain"
if [ $? -eq 0 ]; then
    echo -e "${GREEN}✅ SSL 证书配置正确${NC}"
else
    echo -e "${RED}❌ SSL 证书有问题${NC}"
fi

echo ""
echo "6. 检查项目文件..."
if [ -f "/mnt/d/openclaw/autoCode/my-vue-app/dist/index.html" ]; then
    echo -e "${GREEN}✅ 项目文件存在${NC}"
else
    echo -e "${RED}❌ 项目文件不存在${NC}"
fi

echo ""
echo "7. 检查证书文件..."
if [ -f "/mnt/d/ideaProject/testMaven/nginx/cert/dell.codekfc.top.pem" ] && [ -f "/mnt/d/ideaProject/testMaven/nginx/cert/dell.codekfc.top.key" ]; then
    echo -e "${GREEN}✅ 证书文件存在${NC}"
else
    echo -e "${RED}❌ 证书文件不存在${NC}"
fi

echo ""
echo "📊 验证完成"
echo "访问地址: https://localhost:16321"
echo "或: https://dell.codekfc.top:16321"
echo ""
echo "🔧 故障排除:"
echo "  查看错误日志: sudo tail -f /var/log/nginx/error.log"
echo "  重启 Nginx: sudo systemctl restart nginx"
echo "  检查配置: sudo nginx -t"