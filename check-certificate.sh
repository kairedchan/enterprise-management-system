#!/bin/bash

echo "🔐 SSL 证书检查脚本"
echo ""

CERT_KEY="/mnt/d/ideaProject/testMaven/nginx/cert/dell.codekfc.top.key"
CERT_PEM="/mnt/d/ideaProject/testMaven/nginx/cert/dell.codekfc.top.pem"

echo "1️⃣  检查证书文件权限:"
ls -la "$CERT_KEY" "$CERT_PEM" 2>/dev/null || echo "文件不存在"

echo ""
echo "2️⃣  检查私钥格式:"
if openssl rsa -in "$CERT_KEY" -check -noout 2>/dev/null; then
    echo "✅ 私钥格式正确"
else
    echo "❌ 私钥格式错误或密码保护"
fi

echo ""
echo "3️⃣  检查证书格式:"
if openssl x509 -in "$CERT_PEM" -text -noout 2>/dev/null; then
    echo "✅ 证书格式正确"
else
    echo "❌ 证书格式错误"
fi

echo ""
echo "4️⃣  查看证书详细信息:"
openssl x509 -in "$CERT_PEM" -text -noout 2>/dev/null | grep -E "Subject:|Issuer:|Not Before|Not After|DNS:" | head -10

echo ""
echo "5️⃣  检查证书有效期:"
openssl x509 -in "$CERT_PEM" -dates -noout 2>/dev/null

echo ""
echo "6️⃣  检查证书和私钥是否匹配:"
CERT_MODULUS=$(openssl x509 -in "$CERT_PEM" -modulus -noout 2>/dev/null | openssl md5)
KEY_MODULUS=$(openssl rsa -in "$CERT_KEY" -modulus -noout 2>/dev/null | openssl md5)

if [ "$CERT_MODULUS" = "$KEY_MODULUS" ] && [ -n "$CERT_MODULUS" ]; then
    echo "✅ 证书和私钥匹配"
else
    echo "❌ 证书和私钥不匹配"
    echo "   证书MD5: $CERT_MODULUS"
    echo "   私钥MD5: $KEY_MODULUS"
fi

echo ""
echo "7️⃣  测试证书链（如果可用）:"
if openssl verify -CAfile "$CERT_PEM" "$CERT_PEM" 2>/dev/null | grep -q "OK"; then
    echo "✅ 证书链验证通过"
else
    echo "⚠️  证书链验证失败（可能为自签名证书）"
fi

echo ""
echo "📋 证书配置建议:"
echo "1. 确保 Nginx 进程用户有证书文件读取权限"
echo "2. 私钥文件权限应设置为 600 (chmod 600 *.key)"
echo "3. 证书文件权限可设置为 644 (chmod 644 *.pem)"
echo "4. 如果使用自签名证书，客户端可能需要手动信任"
echo ""
echo "🔧 修复权限命令:"
echo "sudo chmod 600 $CERT_KEY"
echo "sudo chmod 644 $CERT_PEM"
echo "sudo chown root:root $CERT_KEY $CERT_PEM"