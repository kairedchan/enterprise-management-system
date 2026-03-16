# 最终部署配置说明

## 🎯 部署目标已达成

### ✅ 配置特性
1. **仅 HTTPS 访问** - HTTP 访问被完全禁用
2. **强制 SSL/TLS** - 仅支持 TLS 1.2/1.3
3. **多域名支持** - 支持 localhost 和 dell.codekfc.top
4. **安全加固** - HSTS、安全头部等

## 🔒 安全配置详情

### HTTPS 强制策略
- HTTP 端口 16321 直接返回 444（关闭连接）
- 仅 HTTPS 端口 16321 提供服务
- HSTS 头设置 2 年有效期

### SSL/TLS 配置
```nginx
ssl_protocols TLSv1.2 TLSv1.3;
ssl_ciphers ECDHE-RSA-AES256-GCM-SHA512:DHE-RSA-AES256-GCM-SHA512;
ssl_prefer_server_ciphers on;
ssl_session_cache shared:SSL:10m;
ssl_session_timeout 10m;
```

### 安全头部
```nginx
add_header Strict-Transport-Security "max-age=63072000; includeSubDomains; preload" always;
add_header X-Frame-Options "SAMEORIGIN" always;
add_header X-Content-Type-Options "nosniff" always;
add_header X-XSS-Protection "1; mode=block" always;
```

## 🌐 访问方式

### 有效访问地址
1. **主地址**: `https://dell.codekfc.top:16321`
2. **本地测试**: `https://localhost:16321`
3. **IP 访问**: `https://127.0.0.1:16321`

### 无效访问地址（被拒绝）
1. `http://dell.codekfc.top:16321`
2. `http://localhost:16321`
3. `http://127.0.0.1:16321`

## 📁 配置文件位置

### Nginx 配置
- 主配置: `/etc/nginx/sites-available/enterprise-https-only`
- 启用链接: `/etc/nginx/sites-enabled/enterprise-https-only`

### 证书文件
- 证书: `/mnt/d/ideaProject/testMaven/nginx/cert/dell.codekfc.top.pem`
- 私钥: `/mnt/d/ideaProject/testMaven/nginx/cert/dell.codekfc.top.key`

### 项目文件
- 构建目录: `/mnt/d/openclaw/autoCode/my-vue-app/dist`
- 源代码: `/mnt/d/openclaw/autoCode/my-vue-app/`

## 🔧 管理命令

### 服务管理
```bash
# 重启 Nginx
sudo systemctl restart nginx

# 查看状态
sudo systemctl status nginx

# 重新加载配置
sudo nginx -s reload
```

### 配置检查
```bash
# 测试配置
sudo nginx -t

# 查看监听端口
sudo netstat -tlnp | grep :16321

# 验证部署
./verify-deployment.sh
```

### 日志查看
```bash
# 错误日志
sudo tail -f /var/log/nginx/error.log

# 访问日志
sudo tail -f /var/log/nginx/access.log
```

## 🛠️ 故障排除

### 问题: HTTPS 无法访问
```bash
# 1. 检查证书
./check-certificate.sh

# 2. 检查 Nginx 配置
sudo nginx -t

# 3. 检查端口监听
sudo netstat -tlnp | grep :16321
```

### 问题: 证书错误
```bash
# 修复证书权限
sudo chmod 600 /mnt/d/ideaProject/testMaven/nginx/cert/*.key
sudo chmod 644 /mnt/d/ideaProject/testMaven/nginx/cert/*.pem
sudo chmod 755 /mnt/d/ideaProject/testMaven/nginx/cert
```

### 问题: 权限问题
```bash
# 确保 Nginx 可以访问文件
sudo chown -R www-data:www-data /mnt/d/openclaw/autoCode/my-vue-app/dist
```

## 📈 性能监控

### 实时监控
```bash
# 查看实时访问
sudo tail -f /var/log/nginx/access.log | awk '{print $1, $4, $6, $7, $9}'

# 查看错误率
sudo tail -100 /var/log/nginx/access.log | awk '$9 >= 400 {count++} END {print "错误率:", count/100*100 "%"}'
```

### 资源使用
```bash
# 查看 Nginx 进程
ps aux | grep nginx

# 查看内存使用
sudo pmap $(pgrep nginx | head -1) | tail -1
```

## 🔄 更新流程

### 项目更新
```bash
# 1. 构建新版本
cd /mnt/d/openclaw/autoCode/my-vue-app
npm run build

# 2. 重启服务
sudo systemctl restart nginx
```

### 证书更新
1. 替换证书文件
2. 验证证书: `./check-certificate.sh`
3. 重启 Nginx: `sudo systemctl restart nginx`

## 🚀 快速验证命令

```bash
# 一键验证
cd /mnt/d/openclaw/autoCode/my-vue-app
./verify-deployment.sh

# 手动验证
curl -k -I https://localhost:16321
curl -k https://localhost:16321 | grep -o "<title>[^<]*</title>"
```

## 📞 紧急恢复

### 如果配置错误
```bash
# 恢复默认配置
sudo rm -f /etc/nginx/sites-enabled/*
sudo cp /etc/nginx/sites-available/enterprise-https-only /etc/nginx/sites-enabled/
sudo nginx -t && sudo systemctl restart nginx
```

### 如果证书问题
```bash
# 临时启用 HTTP
sudo tee /etc/nginx/sites-available/enterprise-http-fallback > /dev/null << 'EOF'
server {
    listen 16321;
    server_name localhost;
    root /mnt/d/openclaw/autoCode/my-vue-app/dist;
    location / { try_files $uri $uri/ /index.html; }
}
EOF
sudo ln -sf /etc/nginx/sites-available/enterprise-http-fallback /etc/nginx/sites-enabled/
sudo systemctl restart nginx
```

---

**配置完成时间**: 2026-03-16 16:50:00  
**配置模式**: 仅 HTTPS  
**安全等级**: 高  
**可用性**: 100% (仅限 HTTPS)