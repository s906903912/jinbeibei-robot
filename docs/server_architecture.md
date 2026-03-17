# WebSocket 服务器架构

## 🖥️ 技术选型

**方案 A: Node.js + ws** ⭐ 推荐
- 轻量级，适合 IoT 场景
- 开发简单，生态丰富
- 可部署在本地电脑/树莓派/云服务器

**方案 B: Go + gorilla/websocket**
- 性能更好，并发能力强
- 适合大规模部署
- 开发成本稍高

**方案 C: Python + FastAPI + websockets**
- 适合快速原型
- 便于集成 AI 功能
- 性能中等

## 🏗️ 服务器架构（Node.js 方案）

```
┌─────────────────────────────────────────────────────────┐
│                  WebSocket 服务器                        │
│  ┌───────────────────────────────────────────────────┐  │
│  │  连接管理模块                                      │  │
│  │  - 设备连接 (ESP32-S3)                            │  │
│  │  - APP 连接 (iOS/Android)                          │  │
│  │  - 会话保持、心跳检测                             │  │
│  └───────────────────────────────────────────────────┘  │
│  ┌───────────────────────────────────────────────────┐  │
│  │  消息路由模块                                      │  │
│  │  - APP → 设备：转发控制命令                       │  │
│  │  - 设备 → APP: 转发状态/回复                      │  │
│  │  - 广播消息：群聊、通知                          │  │
│  └───────────────────────────────────────────────────┘  │
│  ┌───────────────────────────────────────────────────┐  │
│  │  大模型集成模块                                    │  │
│  │  - Qwen API 调用                                   │  │
│  │  - 对话上下文管理                                 │  │
│  │  - 意图识别                                       │  │
│  └───────────────────────────────────────────────────┘  │
│  ┌───────────────────────────────────────────────────┐  │
│  │  数据存储模块                                      │  │
│  │  - 设备信息                                       │  │
│  │  - 对话历史                                       │  │
│  │  - 闹钟配置                                       │  │
│  └───────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────┘
```

## 📁 项目结构

```
jinbeibei-server/
├── package.json
├── src/
│   ├── index.js              # 服务器入口
│   ├── config/               # 配置
│   │   └── index.js
│   ├── websocket/            # WebSocket 处理
│   │   ├── server.js         # WebSocket 服务器
│   │   ├── device_handler.js # 设备连接处理
│   │   └── app_handler.js    # APP 连接处理
│   ├── routes/               # HTTP API 路由
│   │   ├── device.js         # 设备管理
│   │   ├── alarm.js          # 闹钟管理
│   │   └── chat.js           # 对话 API
│   ├── services/             # 业务逻辑
│   │   ├── llm_service.js    # 大模型服务
│   │   ├── device_service.js # 设备管理
│   │   └── alarm_service.js  # 闹钟服务
│   ├── models/               # 数据模型
│   │   ├── Device.js
│   │   ├── Alarm.js
│   │   └── Message.js
│   └── utils/                # 工具函数
│       └── logger.js
├── data/                     # 数据存储（SQLite/JSON）
└── logs/                     # 日志文件
```

## 💻 核心代码示例

### package.json
```json
{
  "name": "jinbeibei-server",
  "version": "1.0.0",
  "main": "src/index.js",
  "scripts": {
    "start": "node src/index.js",
    "dev": "nodemon src/index.js"
  },
  "dependencies": {
    "ws": "^8.14.2",
    "express": "^4.18.2",
    "axios": "^1.6.0",
    "uuid": "^9.0.0",
    "better-sqlite3": "^9.2.2",
    "winston": "^3.11.0",
    "dotenv": "^16.3.1"
  },
  "devDependencies": {
    "nodemon": "^3.0.1"
  }
}
```

### src/index.js
```javascript
const express = require('express');
const WebSocket = require('ws');
const { WebSocketServer } = require('./websocket/server');
const deviceRoutes = require('./routes/device');
const alarmRoutes = require('./routes/alarm');
const chatRoutes = require('./routes/chat');
const config = require('./config');
const logger = require('./utils/logger');

const app = express();
const PORT = config.SERVER_PORT || 8123;

// 中间件
app.use(express.json());
app.use((req, res, next) => {
  logger.info(`${req.method} ${req.path}`);
  next();
});

// HTTP API 路由
app.use('/api/devices', deviceRoutes);
app.use('/api/alarms', alarmRoutes);
app.use('/api/chat', chatRoutes);

// 健康检查
app.get('/health', (req, res) => {
  res.json({ status: 'ok', timestamp: Date.now() });
});

// 启动服务器
const server = app.listen(PORT, () => {
  logger.info(`🚀 金贝贝服务器启动在端口 ${PORT}`);
  logger.info(`📡 WebSocket: ws://localhost:${PORT}`);
  logger.info(`🌐 HTTP API: http://localhost:${PORT}/api`);
});

// WebSocket 服务器
const wss = new WebSocketServer(server);

// 优雅关闭
process.on('SIGTERM', () => {
  logger.info('收到 SIGTERM，正在关闭...');
  wss.close();
  server.close(() => {
    logger.info('服务器已关闭');
    process.exit(0);
  });
});
```

### src/websocket/server.js
```javascript
const WebSocket = require('ws');
const { handleDeviceConnection } = require('./device_handler');
const { handleAppConnection } = require('./app_handler');
const logger = require('../utils/logger');

class WebSocketServer {
  constructor(server) {
    this.wss = new WebSocket.Server({ server });
    this.devices = new Map();    // device_id -> WebSocket
    this.apps = new Map();       // app_id -> WebSocket
    this.init();
  }

  init() {
    this.wss.on('connection', (ws, req) => {
      const params = new URLSearchParams(req.url.split('?')[1]);
      const type = params.get('type');  // 'device' or 'app'
      const id = params.get('id');

      logger.info(`新连接：type=${type}, id=${id}`);

      if (type === 'device') {
        handleDeviceConnection(ws, id, this.devices);
      } else if (type === 'app') {
        handleAppConnection(ws, id, this.apps, this.devices);
      } else {
        ws.close(4000, 'Unknown connection type');
      }
    });

    // 心跳检测
    setInterval(() => {
      this.wss.clients.forEach(ws => {
        if (ws.isAlive === false) {
          return ws.terminate();
        }
        ws.isAlive = false;
        ws.ping();
      });
    }, 30000);
  }

  // 广播消息到设备
  broadcastToDevice(deviceId, message) {
    const ws = this.devices.get(deviceId);
    if (ws && ws.readyState === WebSocket.OPEN) {
      ws.send(JSON.stringify(message));
    }
  }

  // 广播消息到 APP
  broadcastToApp(appId, message) {
    const ws = this.apps.get(appId);
    if (ws && ws.readyState === WebSocket.OPEN) {
      ws.send(JSON.stringify(message));
    }
  }

  close() {
    this.wss.clients.forEach(client => {
      client.close();
    });
  }
}

module.exports = { WebSocketServer };
```

### src/websocket/device_handler.js
```javascript
const logger = require('../utils/logger');

function handleDeviceConnection(ws, deviceId, devices) {
  logger.info(`设备连接：${deviceId}`);
  
  // 注册设备
  devices.set(deviceId, ws);
  ws.deviceId = deviceId;
  ws.isAlive = true;

  // 发送欢迎消息
  ws.send(JSON.stringify({
    type: 'welcome',
    message: '已连接到金贝贝服务器',
    timestamp: Date.now()
  }));

  // 心跳响应
  ws.on('pong', () => {
    ws.isAlive = true;
  });

  // 接收设备消息
  ws.on('message', (data) => {
    try {
      const message = JSON.parse(data);
      logger.info(`设备 ${deviceId} 消息:`, message);
      
      // 根据消息类型处理
      handleMessageFromDevice(deviceId, message, devices);
    } catch (err) {
      logger.error('解析设备消息失败:', err);
    }
  });

  // 断开连接
  ws.on('close', () => {
    logger.info(`设备断开：${deviceId}`);
    devices.delete(deviceId);
  });

  ws.on('error', (err) => {
    logger.error(`设备 ${deviceId} 错误:`, err);
  });
}

function handleMessageFromDevice(deviceId, message, devices) {
  // TODO: 根据消息类型转发给 APP 或处理
  switch (message.type) {
    case 'status_update':
      // 设备状态更新，转发给所有 APP
      break;
    case 'alarm_triggered':
      // 闹钟触发，通知 APP
      break;
    case 'chat_reply':
      // 对话回复，转发给 APP
      break;
  }
}

module.exports = { handleDeviceConnection };
```

## 🔌 API 接口设计

### 设备管理

**GET /api/devices**
```json
{
  "devices": [
    {
      "id": "jinbeibei_001",
      "name": "金贝贝",
      "status": "online",
      "last_seen": 1710669600000
    }
  ]
}
```

**POST /api/devices/:id/emotion**
```json
{
  "emotion": "happy"
}
```

### 闹钟管理

**GET /api/alarms**
```json
{
  "alarms": [
    {
      "id": "alarm_001",
      "time": "07:30",
      "enabled": true,
      "repeat": ["mon", "tue", "wed", "thu", "fri"],
      "label": "起床啦！"
    }
  ]
}
```

**POST /api/alarms**
```json
{
  "time": "08:00",
  "enabled": true,
  "repeat": ["everyday"],
  "label": "该休息啦～"
}
```

### 对话 API

**POST /api/chat**
```json
{
  "device_id": "jinbeibei_001",
  "message": "你好呀",
  "context": []
}
```

**Response**
```json
{
  "reply": "你好主人～🐤 今天过得怎么样？",
  "emotion": "happy"
}
```

## 🚀 部署方案

### 方案 1: 本地部署（开发测试）
- 运行在个人电脑
- 设备/APP 需在同一局域网
- 适合开发调试

### 方案 2: 云服务器部署
- 部署到阿里云/腾讯云
- 设备/APP 通过公网连接
- 需要配置域名和 HTTPS

### 方案 3: 混合部署
- WebSocket 服务器本地运行
- 大模型 API 调用云端
- 平衡隐私和性能

## 📝 下一步

1. ✅ 创建 Node.js 项目框架
2. ⏳ 实现 WebSocket 连接管理
3. ⏳ 实现设备/APP 消息路由
4. ⏳ 集成 Qwen 大模型 API
5. ⏳ 实现 HTTP API 接口
6. ⏳ 数据持久化（SQLite）

---

*金贝贝 WebSocket 服务器 - 连接设备与手机的桥梁！* 🌉🐤
