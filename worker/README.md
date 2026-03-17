# Cloudflare Worker 部署指南

## 📋 前提条件

- Cloudflare 账户
- 已创建 D1 数据库（database_id: d0bcbdb7-642a-4bf0-a204-9b9bae241c99）
- 安装 Node.js

---

## 🚀 部署步骤

### 1. 安装 Wrangler CLI

```bash
npm install -g wrangler
```

### 2. 登录 Cloudflare

```bash
wrangler login
```

会自动打开浏览器，授权后即可。

### 3. 初始化数据库

```bash
cd worker
npm run init-db
```

这会执行 SQL schema，创建所有表。

### 4. 部署 Worker

```bash
npm run deploy
```

部署成功后会显示 Worker URL，例如：
```
https://jinbeibei-api.your-subdomain.workers.dev
```

---

## 🔧 本地开发

```bash
cd worker
npm install
npm run dev
```

本地开发服务器会运行在 `http://localhost:8787`

---

## 📡 API 端点

部署后的 API 地址：`https://jinbeibei-api.your-subdomain.workers.dev`

### 设备管理
- `GET /api/devices` - 获取设备列表
- `POST /api/devices` - 创建设备

### 闹钟管理
- `GET /api/alarms` - 获取闹钟列表
- `POST /api/alarms` - 创建闹钟

### 对话
- `POST /api/chat` - 发送消息

### 健康检查
- `GET /api/health` - 检查服务状态

---

## 🔑 环境变量配置

如果需要配置 Qwen API Key：

```bash
wrangler secret put QWEN_API_KEY
```

输入你的 API Key 即可。

---

## 📝 注意事项

1. D1 数据库已在 `wrangler.toml` 中配置
2. Worker 自动绑定到数据库
3. 免费额额度：每天 100,000 次请求
4. 全球边缘节点，速度快

---

部署完成后，记得更新 Flutter APP 的 API 地址！
