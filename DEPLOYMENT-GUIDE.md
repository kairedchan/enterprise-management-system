# 企业管理系统部署指南

## 📋 部署概述

本项目已配置多种部署方式，支持：
- **HTTP 部署** (端口 16321)
- **HTTPS 部署** (端口 16321，使用 SSL 证书)
- **GitHub Pages** (可选)
- **Docker 部署** (可选)

## 🚀 快速部署

### 方法 1: 使用脚本部署 HTTPS (推荐)

```bash
# 1. 进入项目目录
cd /mnt/d/openclaw/autoCode/my-vue-app

# 2. 运行 HTTPS 部署脚本 (需要 sudo)
sudo ./setup-nginx-https.sh
```

### 方法 2: 使用脚本部署 HTTP

```bash
# 1. 进入项目目录
cd /mnt/d/openclaw/autoCode/my-vue-app

# 2. 运行 HTTP 部署脚本 (需要 sudo)
sudo ./setup-nginx.sh
```

### 方法 3: 手动配置

参考下面的详细配置说明。

## 🔒 HTTPS 详细配置

### 证书信息
- **域名**: dell.codekfc.top
- **证书路径**: `D:\ideaProject\testMaven\nginx\cert`
- **私钥文件**: `dell.codekfc.top.key`
- **证书文件**: `dell.codekfc.top.pem`
- **端口**: 16321

### 证书验证
```bash
# 检查证书配置
./check-certificate.sh

# 查看证书详情
openssl x509 -in /mnt/d/ideaProject/testMaven/nginx/cert/dell.codekfc.top.pem -text -noout
```

### Nginx HTTPS 配置要点

1. **HTTP 重定向到 HTTPS**
```nginx
server {
    listen 80;
    server_name dell.codekfc.top;
    return 301 https://$server_name:16321$request_uri;
}
```

2. **HTTPS 服务器配置**
```nginx
server {
    listen 16321 ssl http2;
    server_name dell.codekfc.top;
    
    ssl_certificate /mnt/d/ideaProject/testMaven/nginx/cert/dell.codekfc.top.pem;
    ssl_certificate_key /mnt/d/ideaProject/testMaven/nginx/cert/dell.codekfc.top.key;
    
    # 安全头部
    add_header Strict-Transport-Security "max-age=63072000" always;
}
```

## 🌐 HTTP 配置（备用）

### 基本配置
```nginx
server {
    listen 16321;
    server_name localhost;
    root /mnt/d/openclaw/autoCode/my-vue-app/dist;
    
    location / {
        try_files $uri $uri/ /index.html;
    }
}
```

### 访问地址
- HTTP: http://localhost:16321
- 或 http://服务器IP:16321

## 📊 部署检查清单

### 前置检查
- [ ] 确保 Node.js 已安装 (`node --version`)
- [ ] 确保 npm 已安装 (`npm --version`)
- [ ] 确保项目已构建 (`npm run build`)
- [ ] 确保 dist 目录存在

### Nginx 检查
- [ ] Nginx 已安装 (`nginx -v`)
- [ ] Nginx 服务运行中 (`systemctl status nginx`)
- [ ] 配置文件语法正确 (`nginx -t`)
- [ ] 防火墙开放端口 (16321)

### HTTPS 专用检查
- [ ] 证书文件存在且可读
- [ ] 证书和私钥匹配
- [ ] 证书未过期
- [ ] 域名解析正确

### 部署后验证
- [ ] 可以访问 http://localhost:16321 (HTTP)
- [ ] 可以访问 https://dell.codekfc.top:16321 (HTTPS)
- [ ] HTTP 自动重定向到 HTTPS (如果配置)
- [ ] 所有页面功能正常

## 🔧 故障排除

### 常见问题 1: Nginx 启动失败
```bash
# 检查错误日志
sudo tail -f /var/log/nginx/error.log

# 测试配置
sudo nginx -t
```

### 常见问题 2: 证书错误
```bash
# 检查证书权限
sudo chmod 600 /mnt/d/ideaProject/testMaven/nginx/cert/*.key
sudo chmod 644 /mnt/d/ideaProject/testMaven/nginx/cert/*.pem

# 验证证书
./check-certificate.sh
```

### 常见问题 3: 端口被占用
```bash
# 检查端口占用
sudo netstat -tlnp | grep :16321

# 如果被占用，修改 Nginx 配置中的端口
```

### 常见问题 4: 权限问题
```bash
# 确保 Nginx 用户可以读取文件和目录
sudo chown -R www-data:www-data /mnt/d/openclaw/autoCode/my-vue-app/dist
sudo chmod -R 755 /mnt/d/openclaw/autoCode/my-vue-app/dist
```

## 📈 性能优化

### 1. 静态资源缓存
```nginx
location ~* \.(js|css|png|jpg|jpeg|gif|ico|svg)$ {
    expires 1y;
    add_header Cache-Control "public, immutable";
}
```

### 2. Gzip 压缩
```nginx
gzip on;
gzip_types text/plain text/css application/json application/javascript text/xml image/svg+xml;
```

### 3. 安全头部
```nginx
add_header X-Frame-Options "SAMEORIGIN" always;
add_header X-Content-Type-Options "nosniff" always;
add_header X-XSS-Protection "1; mode=block" always;
```

## 🐳 Docker 部署（可选）

### 创建 Dockerfile
```dockerfile
FROM nginx:alpine
COPY dist /usr/share/nginx/html
COPY nginx-https.conf /etc/nginx/conf.d/default.conf
EXPOSE 16321
CMD ["nginx", "-g", "daemon off;"]
```

### 构建和运行
```bash
# 构建镜像
docker build -t enterprise-management .

# 运行容器
docker run -d -p 16321:16321 --name enterprise-app enterprise-management
```

## 🔄 持续部署

项目已配置 GitHub Actions，每次推送代码到 main 分支会自动：
1. 安装依赖
2. 构建项目
3. 保存构建产物

可以在 GitHub 仓库的 Actions 页面查看构建状态。

## 📞 支持

如有部署问题，请检查：
1. 错误日志: `/var/log/nginx/error.log`
2. 访问日志: `/var/log/nginx/access.log`
3. 系统日志: `journalctl -u nginx`

或参考脚本中的详细输出信息。