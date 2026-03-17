# 金贝贝 WebSocket 服务器

> 金贝贝桌面精灵的后端服务器 - 连接设备、APP 和大模型

## 🚀 快速开始

### 安装依赖

```bash
npm install
```

### 配置环境变量

复制 `.env.example` 为 `.env`：

```bash
cp .env.example .env
```

编辑 `.env` 文件：

```env
# 服务器端口
PORT=8123

# Qwen API Key（阿里云百炼）
QWEN_API_KEY=your_qwen_api_key_here

# 允许的 CORS 来源（多个用逗号分隔）
ALLOWED_ORIGINS=*
```

### 启动服务器

**开发模式（自动重启）：**
```bash
npm run dev
```

**生产模式：**
```bash
npm start
```

### 验证运行

访问健康检查接口：
```bash
curl http://localhost:8123/health
```

预期响应：
```json
{
  "status": "ok",
  "timestamp": 1710669600000,
  "version": "0.1.0"
}
```

## 📡 WebSocket 连接

### 设备连接

```javascript
const ws = new WebSocket('ws://localhost:8123?type=device&id=jinbeibei_001');

ws.onopen = () => {
  console.log('设备已连接');
};

ws.onmessage = (event) => {
  const message = JSON.parse(event.data);
  console.log('收到消息:', message);
};
```

### APP 连接

```javascript
const ws = new WebSocket('ws://localhost:8123?type=app&id=app_001');

ws.onopen = () => {
  console.log('APP 已连接');
};
```

## 🌐 HTTP API

### 设备管理

**获取设备列表**
```bash
GET /api/devices
```

**控制设备**
```bash
POST /api/devices/:deviceId/control
Content-Type: application/json

{
  "action": "set_emotion",
  "data": { "emotion": "happy" }
}
```

**设置表情**
```bash
POST /api/devices/:deviceId/emotion
Content-Type: application/json

{
  "emotion": "happy"
}
```

**设置音量**
```bash
POST /api/devices/:deviceId/volume
Content-Type: application/json

{
  "volume": 70
}
```

### 闹钟管理

**获取闹钟列表**
```bash
GET /api/alarms
```

**创建闹钟**
```bash
POST /api/alarms
Content-Type: application/json

{
  "deviceId": "jinbeibei_001",
  "time": "07:30",
  "enabled": true,
  "repeat": ["mon", "tue", "wed", "thu", "fri"],
  "label": "起床啦！"
}
```

**删除闹钟**
```bash
DELETE /api/alarms/:alarmId
```

### 对话聊天

**发送消息**
```bash
POST /api/chat
Content-Type: application/json

{
  "deviceId": "jinbeibei_001",
  "message": "你好呀"
}
```

**获取对话历史**
```bash
GET /api/chat/history/:deviceId
```

**清空对话历史**
```bash
DELETE /api/chat/history/:deviceId
```

## 📁 项目结构

```
server/
├── package.json           # 依赖配置
├── .env.example          # 环境变量示例
├── src/
│   ├── index.js          # 服务器入口
│   ├── websocket/
│   │   └── server.js     # WebSocket 服务器
│   └── routes/
│       ├── device.js     # 设备管理 API
│       ├── alarm.js      # 闹钟管理 API
│       └── chat.js       # 对话聊天 API
└── logs/                 # 日志目录
```

## 🔧 开发说明

### 日志

日志文件位于 `logs/` 目录：
- `combined.log` - 所有日志
- `error.log` - 错误日志

### WebSocket 消息格式

**设备 → 服务器**
```json
{
  "type": "status_update",
  "data": {
    "battery": 100,
    "volume": 70
  }
}
```

**服务器 → 设备**
```json
{
  "type": "control",
  "action": "set_emotion",
  "data": {
    "emotion": "happy"
  }
}
```

### 添加新 API

1. 在 `src/routes/` 创建新的路由文件
2. 在 `src/index.js` 中注册路由
3. 更新本文档

## 🚨 注意事项

1. **API Key 安全**: 不要将 `.env` 文件提交到 Git
2. **端口占用**: 确保 8123 端口未被占用
3. **Node 版本**: 建议使用 Node.js 18+

## 📝 待办事项

- [ ] 集成 SQLite 数据库持久化
- [ ] 添加设备认证机制
- [ ] 实现消息队列（高并发场景）
- [ ] 添加监控和告警
- [ ] Docker 容器化部署

---

*金贝贝服务器 - 连接一切的桥梁！* 🌉🐤
