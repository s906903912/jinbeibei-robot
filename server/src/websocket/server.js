/**
 * WebSocket 服务器 - 连接管理
 * 处理设备与 APP 的 WebSocket 连接、消息路由
 */

const WebSocket = require('ws');

class WebSocketServer {
  constructor(httpServer, logger) {
    this.logger = logger;
    this.wss = new WebSocket.Server({ server: httpServer });
    
    // 连接管理
    this.devices = new Map();    // deviceId -> { ws, metadata }
    this.apps = new Map();       // appId -> { ws, metadata }
    
    // 初始化
    this.init();
    
    this.logger.info('[WebSocket] 服务器初始化完成');
  }

  init() {
    // 新连接处理
    this.wss.on('connection', (ws, req) => {
      this.handleConnection(ws, req);
    });

    // 心跳检测（每 30 秒）
    this.heartbeatInterval = setInterval(() => {
      this.checkHeartbeat();
    }, 30000);

    this.logger.info('[WebSocket] 监听器已注册');
  }

  /**
   * 处理新连接
   */
  handleConnection(ws, req) {
    const url = new URL(req.url, `http://${req.headers.host}`);
    const type = url.searchParams.get('type');  // 'device' or 'app'
    const id = url.searchParams.get('id');
    const token = url.searchParams.get('token');

    this.logger.info(`[WebSocket] 新连接 - type=${type}, id=${id}, ip=${req.socket.remoteAddress}`);

    // 初始化连接状态
    ws.isAlive = true;
    ws.deviceId = null;
    ws.appId = null;

    // 心跳响应
    ws.on('pong', () => {
      ws.isAlive = true;
    });

    // 根据类型处理连接
    if (type === 'device' && id) {
      this.registerDevice(ws, id, token);
    } else if (type === 'app' && id) {
      this.registerApp(ws, id, token);
    } else {
      ws.close(4000, 'Invalid connection parameters');
    }

    // 消息处理
    ws.on('message', (data) => {
      this.handleMessage(ws, data);
    });

    // 断开连接
    ws.on('close', (code, reason) => {
      this.handleDisconnect(ws, code, reason);
    });

    // 错误处理
    ws.on('error', (err) => {
      this.logger.error(`[WebSocket] 错误: ${err.message}`);
    });
  }

  /**
   * 注册设备连接
   */
  registerDevice(ws, deviceId, token) {
    // TODO: 验证 token（可选）
    
    this.devices.set(deviceId, {
      ws,
      metadata: {
        connectedAt: Date.now(),
        ip: ws._socket.remoteAddress,
        token
      }
    });

    ws.deviceId = deviceId;

    // 发送欢迎消息
    this.send(ws, {
      type: 'welcome',
      message: '已连接到金贝贝服务器',
      serverTime: Date.now(),
      config: {
        heartbeatInterval: 30000
      }
    });

    this.logger.info(`[WebSocket] 设备已注册 - ${deviceId}`);

    // 通知所有 APP 有新设备上线
    this.broadcastToApps({
      type: 'device_online',
      deviceId,
      timestamp: Date.now()
    });
  }

  /**
   * 注册 APP 连接
   */
  registerApp(ws, appId, token) {
    // TODO: 验证 token（可选）
    
    this.apps.set(appId, {
      ws,
      metadata: {
        connectedAt: Date.now(),
        ip: ws._socket.remoteAddress,
        token
      }
    });

    ws.appId = appId;

    // 发送欢迎消息和当前设备列表
    const deviceList = Array.from(this.devices.keys()).map(id => ({
      id,
      status: 'online'
    }));

    this.send(ws, {
      type: 'welcome',
      message: '已连接到金贝贝服务器',
      serverTime: Date.now(),
      devices: deviceList
    });

    this.logger.info(`[WebSocket] APP 已注册 - ${appId}`);
  }

  /**
   * 处理接收到的消息
   */
  handleMessage(ws, data) {
    try {
      const message = JSON.parse(data.toString());
      this.logger.debug(`[WebSocket] 收到消息: ${JSON.stringify(message)}`);

      // 根据连接类型分发处理
      if (ws.deviceId) {
        this.handleDeviceMessage(ws.deviceId, message);
      } else if (ws.appId) {
        this.handleAppMessage(ws.appId, message);
      }
    } catch (err) {
      this.logger.error(`[WebSocket] 消息解析失败: ${err.message}`);
      this.send(ws, {
        type: 'error',
        message: 'Invalid message format'
      });
    }
  }

  /**
   * 处理设备发来的消息
   */
  handleDeviceMessage(deviceId, message) {
    this.logger.info(`[WebSocket] 设备消息 - ${deviceId}: ${message.type}`);

    switch (message.type) {
      case 'heartbeat':
        // 心跳响应
        this.sendToDevice(deviceId, {
          type: 'heartbeat_ack',
          timestamp: Date.now()
        });
        break;

      case 'status_update':
        // 设备状态更新，转发给所有 APP
        this.broadcastToApps({
          type: 'device_status',
          deviceId,
          data: message.data,
          timestamp: Date.now()
        });
        break;

      case 'chat_request':
        // 对话请求，转发给服务器处理（通过 HTTP API）
        // TODO: 调用 LLM 服务
        break;

      case 'alarm_triggered':
        // 闹钟触发，通知所有 APP
        this.broadcastToApps({
          type: 'alarm_notification',
          deviceId,
          data: message.data,
          timestamp: Date.now()
        });
        break;

      default:
        this.logger.warn(`[WebSocket] 未知消息类型：${message.type}`);
    }
  }

  /**
   * 处理 APP 发来的消息
   */
  handleAppMessage(appId, message) {
    this.logger.info(`[WebSocket] APP 消息 - ${appId}: ${message.type}`);

    switch (message.type) {
      case 'heartbeat':
        this.sendToApp(appId, {
          type: 'heartbeat_ack',
          timestamp: Date.now()
        });
        break;

      case 'control_command':
        // 控制命令，转发给设备
        if (message.deviceId) {
          this.sendToDevice(message.deviceId, {
            type: 'control',
            action: message.action,
            data: message.data,
            timestamp: Date.now()
          });
        }
        break;

      case 'chat_message':
        // 对话消息，转发给设备或处理
        if (message.deviceId) {
          // TODO: 调用 LLM 服务处理后发送给设备
          this.sendToDevice(message.deviceId, {
            type: 'chat_message',
            message: message.message,
            from: 'app',
            timestamp: Date.now()
          });
        }
        break;

      default:
        this.logger.warn(`[WebSocket] 未知消息类型：${message.type}`);
    }
  }

  /**
   * 处理断开连接
   */
  handleDisconnect(ws, code, reason) {
    if (ws.deviceId) {
      this.logger.info(`[WebSocket] 设备断开 - ${ws.deviceId}`);
      this.devices.delete(ws.deviceId);
      
      // 通知所有 APP 设备离线
      this.broadcastToApps({
        type: 'device_offline',
        deviceId: ws.deviceId,
        timestamp: Date.now()
      });
    } else if (ws.appId) {
      this.logger.info(`[WebSocket] APP 断开 - ${ws.appId}`);
      this.apps.delete(ws.appId);
    }
  }

  /**
   * 心跳检测
   */
  checkHeartbeat() {
    this.wss.clients.forEach(ws => {
      if (ws.isAlive === false) {
        return ws.terminate();
      }
      ws.isAlive = false;
      ws.ping();
    });
  }

  /**
   * 发送消息到 WebSocket
   */
  send(ws, message) {
    if (ws.readyState === WebSocket.OPEN) {
      ws.send(JSON.stringify(message));
    }
  }

  /**
   * 发送消息到指定设备
   */
  sendToDevice(deviceId, message) {
    const device = this.devices.get(deviceId);
    if (device && device.ws.readyState === WebSocket.OPEN) {
      this.send(device.ws, message);
      this.logger.debug(`[WebSocket] 发送给设备 ${deviceId}: ${message.type}`);
      return true;
    }
    this.logger.warn(`[WebSocket] 设备不在线：${deviceId}`);
    return false;
  }

  /**
   * 发送消息到指定 APP
   */
  sendToApp(appId, message) {
    const app = this.apps.get(appId);
    if (app && app.ws.readyState === WebSocket.OPEN) {
      this.send(app.ws, message);
      return true;
    }
    return false;
  }

  /**
   * 广播消息到所有 APP
   */
  broadcastToApps(message) {
    let count = 0;
    this.apps.forEach((app, appId) => {
      if (this.sendToApp(appId, message)) {
        count++;
      }
    });
    this.logger.debug(`[WebSocket] 广播给 ${count} 个 APP: ${message.type}`);
  }

  /**
   * 广播消息到所有设备
   */
  broadcastToDevices(message) {
    let count = 0;
    this.devices.forEach((device, deviceId) => {
      if (this.sendToDevice(deviceId, message)) {
        count++;
      }
    });
    this.logger.debug(`[WebSocket] 广播给 ${count} 个设备：${message.type}`);
  }

  /**
   * 获取在线设备列表
   */
  getOnlineDevices() {
    return Array.from(this.devices.entries()).map(([id, data]) => ({
      id,
      status: 'online',
      connectedAt: data.metadata.connectedAt,
      ip: data.metadata.ip
    }));
  }

  /**
   * 获取在线 APP 列表
   */
  getOnlineApps() {
    return Array.from(this.apps.entries()).map(([id, data]) => ({
      id,
      connectedAt: data.metadata.connectedAt,
      ip: data.metadata.ip
    }));
  }

  /**
   * 关闭服务器
   */
  close() {
    if (this.heartbeatInterval) {
      clearInterval(this.heartbeatInterval);
    }
    
    this.wss.clients.forEach(client => {
      client.close(1001, 'Server shutting down');
    });
    
    this.logger.info('[WebSocket] 服务器已关闭');
  }
}

module.exports = WebSocketServer;
