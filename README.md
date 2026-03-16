# 企业管理系统前端

基于 Vue 3 + TypeScript + Element Plus 构建的企业管理系统前端界面。

[![Deploy Vue App](https://github.com/Kairedchan/enterprise-management-system/actions/workflows/deploy.yml/badge.svg)](https://github.com/Kairedchan/enterprise-management-system/actions/workflows/deploy.yml)

## 项目概述

这是一个现代化、响应式的企业管理后台系统，参考了企业微信的管理界面设计风格，提供了用户管理、文档管理、数据统计等核心功能。

## 技术栈

- **Vue 3** - 渐进式 JavaScript 框架
- **TypeScript** - JavaScript 的超集，提供类型安全
- **Element Plus** - 基于 Vue 3 的桌面端组件库
- **Vite** - 下一代前端构建工具
- **ESLint** - 代码质量检查工具

## 功能特性

- ✅ 响应式设计，支持移动端和桌面端
- ✅ 现代化管理后台界面
- ✅ 数据统计卡片展示
- ✅ 操作记录表格
- ✅ 用户管理功能
- ✅ 文档管理功能
- ✅ 系统设置面板

## 界面预览

界面采用企业微信风格设计，包含：

1. **顶部导航栏** - 企业 Logo 和用户信息
2. **左侧菜单栏** - 功能导航菜单
3. **主内容区** - 仪表板和数据展示
4. **底部信息栏** - 版权和版本信息

## 项目结构

```
my-vue-app/
├── src/
│   ├── assets/          # 静态资源
│   ├── components/      # 组件目录
│   ├── plugins/         # 插件配置
│   │   └── element-plus.ts  # Element Plus 插件
│   ├── App.vue         # 主应用组件
│   └── main.ts         # 应用入口
├── public/             # 公共资源
├── index.html          # HTML 模板
├── package.json        # 依赖管理
├── tsconfig.json       # TypeScript 配置
└── vite.config.ts      # Vite 配置
```

## 安装和运行

### 环境要求

- Node.js 16.0 或更高版本
- npm 或 yarn 包管理器

### 安装依赖

```bash
npm install
```

### 开发模式运行

```bash
npm run dev
```

### 生产构建

```bash
npm run build
```

### 预览构建结果

```bash
npm run preview
```

## 部署

项目构建后，将 `dist` 目录下的文件部署到任何静态文件服务器或 Web 服务器（如 Nginx）即可。

## 开发说明

1. 项目使用组合式 API (Composition API)
2. 所有组件均使用 `<script setup>` 语法
3. 使用 TypeScript 提供类型安全
4. 遵循 Element Plus 组件使用规范

## 许可证

MIT License