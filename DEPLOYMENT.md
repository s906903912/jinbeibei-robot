# 金贝贝桌面精灵 - 部署指南

> 快速部署金贝贝到本地电脑或云服务器

## 📋 部署方案

### 方案一：本地电脑部署（推荐开发阶段）⭐

**优点：**
- ✅ 免费
- ✅ 调试方便
- ✅ 延迟低

**缺点：**
- ❌ 电脑关机后服务中断
- ❌ 外网无法访问

**适用场景：** 开发测试、同一局域网内使用

#### 部署步骤

**1. 安装 Node.js**

下载并安装 Node.js 18+：
- macOS: `brew install node`
- Windows: 从 https://nodejs.org/ 下载安装
- Linux: `curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash - && sudo apt-get install -y nodejs`

**2. 克隆项目**

```bash
git clone https://github.com/s906903912/jinbeibei-robot.git
cd jinbeibei-robot/server
```

**3. 安装依赖**

```bash
npm install
```

**4. 配置环境变量**

```bash
cp .env.example .env
```

编辑 `.env` 文件：

```env
# 服务器端口
PORT=8123

# Qwen API Key（可选，不配置则使用 Mock 回复）
QWEN_API_KEY=your_qwen_api_key_here

# 允许的 CORS 来源
ALLOWED_ORIGINS=*
```

**5. 启动服务器**

```bash
# 开发模式（自动重启）
npm run dev

# 或生产模式
npm start
```

**6. 验证运行**

访问：http://localhost:8123/health

看到以下响应表示成功：

```json
{
  "status": "ok",
  "timestamp": 1710669600000,
  "version": "0.1.0"
}
```

**7. 获取本机 IP 地址**

- macOS/Linux: `ifconfig | grep "inet "`
- Windows: `ipconfig`

找到类似 `192.168.1.x` 的地址，这就是服务器地址。

**8. 配置 APP 连接**

在 Flutter APP 中设置服务器地址为：
```
ws://192.168.1.x:8123
http://192.168.1.x:8123
```

---

### 方案二：云服务器部署（推荐生产环境）

**优点：**
- ✅ 24 小时运行
- ✅ 外网可访问
- ✅ 稳定可靠

**缺点：**
- ❌ 需要付费（¥10-30/月）
- ❌ 配置稍复杂

**适用场景：** 正式使用、多地点访问

#### 云服务器选择

**推荐配置：**
- CPU: 1 核
- 内存：512MB - 1GB
- 硬盘：10GB
- 带宽：1Mbps

**推荐服务商：**
- 阿里云轻量应用服务器（¥12/月起）
- 腾讯云轻量应用服务器（¥10/月起）
- 华为云（¥9.9/月起）

#### 部署步骤（以阿里云为例）

**1. 购买服务器**

选择 Ubuntu 22.04 系统

**2. SSH 连接服务器**

```bash
ssh root@your_server_ip
```

**3. 安装 Node.js**

```bash
curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
sudo apt-get install -y nodejs
node -v  # 验证版本
```

**4. 克隆项目**

```bash
apt-get install -y git
git clone https://github.com/s906903912/jinbeibei-robot.git
cd jinbeibei-robot/server
```

**5. 安装依赖**

```bash
npm install
```

**6. 配置环境变量**

```bash
cp .env.example .env
nano .env
```

配置内容：

```env
PORT=8123
QWEN_API_KEY=your_qwen_api_key_here
ALLOWED_ORIGINS=*
```

**7. 安装 PM2（进程管理）**

```bash
npm install -g pm2
```

**8. 启动服务**

```bash
pm2 start src/index.js --name jinbeibei-server
pm2 save
pm2 startup
```

**9. 配置防火墙**

阿里云控制台 → 安全组 → 添加规则：
- 端口：8123
- 协议：TCP
- 授权对象：0.0.0.0/0

**10. 验证运行**

访问：http://your_server_ip:8123/health

**11. 配置 APP 连接**

在 Flutter APP 中设置服务器地址为：
```
ws://your_server_ip:8123
http://your_server_ip:8123
```

---

### 方案三：Docker 容器化部署（高级）

**优点：**
- ✅ 环境隔离
- ✅ 便于迁移
- ✅ 版本管理方便

**缺点：**
- ❌ 需要 Docker 知识

#### 部署步骤

**1. 创建 Dockerfile**

在 `server/` 目录创建 `Dockerfile`：

```dockerfile
FROM node:18-alpine

WORKDIR /app

COPY package*.json ./
RUN npm install --production

COPY . .

EXPOSE 8123

CMD ["node", "src/index.js"]
```

**2. 构建镜像**

```bash
docker build -t jinbeibei-server .
```

**3. 运行容器**

```bash
docker run -d \
  --name jinbeibei \
  -p 8123:8123 \
  -e QWEN_API_KEY=your_key \
  jinbeibei-server
```

**4. 查看日志**

```bash
docker logs -f jinbeibei
```

---

## 🔧 常见问题

### 1. 端口被占用

**错误：** `Error: listen EADDRINUSE: address already in use :::8123`

**解决：** 修改 `.env` 中的端口
```env
PORT=8124
```

### 2. WebSocket 连接失败

**检查：**
- 防火墙是否开放端口
- 服务器是否运行
- IP 地址是否正确

### 3. Qwen API 调用失败

**检查：**
- API Key 是否正确
- 网络连接是否正常
- 余额是否充足

### 4. 服务器自动关闭

**解决：** 使用 PM2 管理进程
```bash
pm2 start src/index.js --name jinbeibei --restart-delay=3000
pm2 save
```

---

## 📊 性能优化

### 1. 启用 HTTPS（云服务器）

使用 Nginx 反向代理：

```nginx
server {
    listen 443 ssl;
    server_name your_domain.com;

    ssl_certificate /path/to/cert.pem;
    ssl_certificate_key /path/to/key.pem;

    location / {
        proxy_pass http://localhost:8123;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_cache_bypass $http_upgrade;
    }
}
```

### 2. 数据库优化

后续将 SQLite 替换为 MySQL/PostgreSQL

### 3. 缓存优化

使用 Redis 缓存对话历史

---

## 📝 维护指南

### 查看日志

```bash
# PM2 日志
pm2 logs jinbeibei-server

# 或查看日志文件
tail -f logs/combined.log
```

### 重启服务

```bash
pm2 restart jinbeibei-server
```

### 停止服务

```bash
pm2 stop jinbeibei-server
```

### 更新代码

```bash
git pull
npm install
pm2 restart jinbeibei-server
```

---

## 🎯 下一步

1. ✅ 选择部署方案
2. ✅ 部署服务器
3. ⏳ 配置 APP 连接
4. ⏳ 测试功能
5. ⏳ 固件开发

---

*金贝贝部署指南 - 让服务跑起来！* 🚀🐤
