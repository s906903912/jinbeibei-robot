/**
 * 金贝贝 WebSocket 服务器 - 主入口
 * JinBeibei Desktop Pet - WebSocket Server
 * 
 * @author Auther & 哈基米
 * @version 0.1.0
 * @date 2026-03-17
 */

const express = require('express');
const http = require('http');
const WebSocket = require('ws');
const cors = require('cors');
const dotenv = require('dotenv');
const winston = require('winston');

// 加载环境变量
dotenv.config();

// 导入模块
const WebSocketServer = require('./websocket/server');
const deviceRoutes = require('./routes/device');
const alarmRoutes = require('./routes/alarm');
const chatRoutes = require('./routes/chat');

// 配置
const CONFIG = {
  SERVER_PORT: process.env.PORT || 8123,
  QWEN_API_KEY: process.env.QWEN_API_KEY || '',
  ALLOWED_ORIGINS: process.env.ALLOWED_ORIGINS?.split(',') || ['*']
};

// 日志配置
const logger = winston.createLogger({
  level: 'info',
  format: winston.format.combine(
    winston.format.timestamp({ format: 'YYYY-MM-DD HH:mm:ss' }),
    winston.format.printf(({ timestamp, level, message }) => {
      return `${timestamp} [${level.toUpperCase()}] ${message}`;
    })
  ),
  transports: [
    new winston.transports.Console(),
    new winston.transports.File({ filename: 'logs/error.log', level: 'error' }),
    new winston.transports.File({ filename: 'logs/combined.log' })
  ]
});

// 创建 Express 应用
const app = express();

// 中间件
app.use(cors({
  origin: CONFIG.ALLOWED_ORIGINS,
  credentials: true
}));
app.use(express.json());
app.use((req, res, next) => {
  logger.info(`${req.method} ${req.path} - ${req.ip}`);
  next();
});

// HTTP API 路由
app.use('/api/devices', deviceRoutes);
app.use('/api/alarms', alarmRoutes);
app.use('/api/chat', chatRoutes);

// 健康检查
app.get('/health', (req, res) => {
  res.json({ 
    status: 'ok', 
    timestamp: Date.now(),
    version: '0.1.0'
  });
});

// 404 处理
app.use((req, res) => {
  res.status(404).json({ error: 'Not Found' });
});

// 错误处理
app.use((err, req, res, next) => {
  logger.error('服务器错误:', err);
  res.status(500).json({ error: 'Internal Server Error' });
});

// 创建 HTTP 服务器
const server = http.createServer(app);

// 启动服务器
server.listen(CONFIG.SERVER_PORT, () => {
  logger.info('╔════════════════════════════════════════╗');
  logger.info('║   金贝贝桌面精灵 - WebSocket 服务器      ║');
  logger.info('║          Version 0.1.0                 ║');
  logger.info('╚════════════════════════════════════════╝');
  logger.info(`🚀 服务器启动在端口 ${CONFIG.SERVER_PORT}`);
  logger.info(`📡 WebSocket: ws://localhost:${CONFIG.SERVER_PORT}`);
  logger.info(`🌐 HTTP API: http://localhost:${CONFIG.SERVER_PORT}/api`);
  logger.info(`💡 健康检查：http://localhost:${CONFIG.SERVER_PORT}/health`);
});

// WebSocket 服务器
const wss = new WebSocketServer(server, logger);

// 优雅关闭
process.on('SIGTERM', () => {
  logger.info('收到 SIGTERM，正在关闭...');
  wss.close();
  server.close(() => {
    logger.info('服务器已关闭');
    process.exit(0);
  });
});

process.on('SIGINT', () => {
  logger.info('收到 SIGINT，正在关闭...');
  wss.close();
  server.close(() => {
    logger.info('服务器已关闭');
    process.exit(0);
  });
});

module.exports = { app, server, wss, logger };
