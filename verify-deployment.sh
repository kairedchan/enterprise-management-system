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
if sudo netstat -tlnp 2>/dev/null | grep -q ":16321" || sudo ss -tlnp 2>/dev/null | grep -q ":16321"; then
    echo -e "${GREEN}✅ 端口 16321 正在监听${NC}"
    # 显示监听信息
    if sudo netstat -tlnp 2>/dev/null | grep -q ":16321"; then
        sudo netstat -tlnp 2>/dev/null | grep ":16321"
    else
        sudo ss -tlnp 2>/dev/null | grep ":16321"
    fi
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
HTTP_RESULT=$(timeout 3 curl -I http://localhost:16321 2>&1)
if echo "$HTTP_RESULT" | grep -q "Empty reply from server" || echo "$HTTP_RESULT" | grep -q "curl:"; then
    echo -e "${GREEN}✅ HTTP 访问被正确拒绝（返回444）${NC}"
    echo "   响应: Empty reply from server"
elif echo "$HTTP_RESULT" | grep -q "200 OK"; then
    echo -e "${RED}❌ HTTP 访问不应该成功${NC}"
else
    echo -e "${YELLOW}⚠️  HTTP 访问返回意外响应${NC}"
    echo "   响应: $(echo "$HTTP_RESULT" | head -1)"
fi

echo ""
echo "5. 测试 SSL 证书..."
SSL_RESULT=$(timeout 3 openssl s_client -connect localhost:16321 -servername dell.codekfc.top 2>&1)
if echo "$SSL_RESULT" | grep -q "Certificate chain" || echo "$SSL_RESULT" | grep -q "SSL handshake has read"; then
    echo -e "${GREEN}✅ SSL 证书配置正确${NC}"
    # 提取证书信息摘要
    CERT_INFO=$(echo "$SSL_RESULT" | grep -E "(Certificate chain|Verify|^  *" | head -5)
    echo "   证书信息: $(echo "$CERT_INFO" | tr '\n' ';' | cut -c1-60)..."
elif echo "$SSL_RESULT" | grep -q "connect: Connection refused"; then
    echo -e "${RED}❌ SSL 连接被拒绝${NC}"
else
    echo -e "${YELLOW}⚠️  SSL 测试返回意外结果${NC}"
    echo "   结果: $(echo "$SSL_RESULT" | head -2 | tr '\n' ' ')"
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
CERT_PEM="/mnt/d/ideaProject/testMaven/nginx/cert/dell.codekfc.top.pem"
CERT_KEY="/mnt/d/ideaProject/testMaven/nginx/cert/dell.codekfc.top.key"
if [ -f "$CERT_PEM" ] && [ -f "$CERT_KEY" ]; then
    echo -e "${GREEN}✅ 证书文件存在${NC}"
    
    # 检查证书权限
    PEM_PERM=$(stat -c "%a" "$CERT_PEM" 2>/dev/null || echo "未知")
    KEY_PERM=$(stat -c "%a" "$CERT_KEY" 2>/dev/null || echo "未知")
    echo "   证书权限: pem=$PEM_PERM, key=$KEY_PERM"
    
    # 检查证书有效性
    if openssl x509 -in "$CERT_PEM" -noout 2>/dev/null; then
        echo -e "${GREEN}   证书格式有效${NC}"
    else
        echo -e "${RED}   证书格式无效${NC}"
    fi
else
    echo -e "${RED}❌ 证书文件不存在${NC}"
fi

echo ""
echo "8. 检查 Nginx 配置..."
if sudo nginx -t 2>/dev/null; then
    echo -e "${GREEN}✅ Nginx 配置语法正确${NC}"
else
    echo -e "${RED}❌ Nginx 配置有错误${NC}"
    sudo nginx -t 2>&1 | tail -3
fi

echo ""
echo "9. 检查实际页面访问..."
PAGE_RESULT=$(timeout 5 curl -k -s https://localhost:16321 2>&1)
if echo "$PAGE_RESULT" | grep -q "<html" || echo "$PAGE_RESULT" | grep -q "DOCTYPE"; then
    echo -e "${GREEN}✅ 页面可以正常访问${NC}"
    TITLE=$(echo "$PAGE_RESULT" | grep -o "<title>[^<]*</title>" | sed 's/<[^>]*>//g')
    echo "   页面标题: ${TITLE:-未找到}"
elif echo "$PAGE_RESULT" | grep -q "curl:"; then
    echo -e "${RED}❌ 页面访问失败${NC}"
else
    echo -e "${YELLOW}⚠️  页面访问返回意外内容${NC}"
    echo "   响应长度: ${#PAGE_RESULT} 字符"
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