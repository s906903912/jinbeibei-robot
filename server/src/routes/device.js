/**
 * 设备管理 HTTP API
 */

const express = require('express');
const router = express.Router();

// 获取设备列表（从 WebSocket 服务器获取）
router.get('/', (req, res) => {
  const { wss } = req.app.locals;
  
  const devices = wss ? wss.getOnlineDevices() : [];
  
  res.json({
    success: true,
    devices,
    timestamp: Date.now()
  });
});

// 获取单个设备信息
router.get('/:deviceId', (req, res) => {
  const { deviceId } = req.params;
  const { wss } = req.app.locals;
  
  if (!wss) {
    return res.status(500).json({
      success: false,
      error: 'WebSocket server not available'
    });
  }
  
  const devices = wss.getOnlineDevices();
  const device = devices.find(d => d.id === deviceId);
  
  if (!device) {
    return res.status(404).json({
      success: false,
      error: 'Device not found'
    });
  }
  
  res.json({
    success: true,
    device,
    timestamp: Date.now()
  });
});

// 发送控制命令到设备
router.post('/:deviceId/control', (req, res) => {
  const { deviceId } = req.params;
  const { action, data } = req.body;
  const { wss } = req.app.locals;
  
  if (!wss) {
    return res.status(500).json({
      success: false,
      error: 'WebSocket server not available'
    });
  }
  
  const message = {
    type: 'control_command',
    action,
    data,
    timestamp: Date.now()
  };
  
  const sent = wss.sendToDevice(deviceId, message);
  
  if (sent) {
    res.json({
      success: true,
      message: 'Command sent',
      timestamp: Date.now()
    });
  } else {
    res.status(404).json({
      success: false,
      error: 'Device not found or offline'
    });
  }
});

// 设置设备表情
router.post('/:deviceId/emotion', (req, res) => {
  const { deviceId } = req.params;
  const { emotion } = req.body;
  const { wss } = req.app.locals;
  
  if (!emotion) {
    return res.status(400).json({
      success: false,
      error: 'Emotion is required'
    });
  }
  
  if (!wss) {
    return res.status(500).json({
      success: false,
      error: 'WebSocket server not available'
    });
  }
  
  const sent = wss.sendToDevice(deviceId, {
    type: 'control_command',
    action: 'set_emotion',
    data: { emotion },
    timestamp: Date.now()
  });
  
  if (sent) {
    res.json({
      success: true,
      message: `Emotion set to ${emotion}`,
      timestamp: Date.now()
    });
  } else {
    res.status(404).json({
      success: false,
      error: 'Device not found or offline'
    });
  }
});

// 设置设备音量
router.post('/:deviceId/volume', (req, res) => {
  const { deviceId } = req.params;
  const { volume } = req.body;
  const { wss } = req.app.locals;
  
  if (volume === undefined || volume < 0 || volume > 100) {
    return res.status(400).json({
      success: false,
      error: 'Volume must be between 0 and 100'
    });
  }
  
  if (!wss) {
    return res.status(500).json({
      success: false,
      error: 'WebSocket server not available'
    });
  }
  
  const sent = wss.sendToDevice(deviceId, {
    type: 'control_command',
    action: 'set_volume',
    data: { volume },
    timestamp: Date.now()
  });
  
  if (sent) {
    res.json({
      success: true,
      message: `Volume set to ${volume}`,
      timestamp: Date.now()
    });
  } else {
    res.status(404).json({
      success: false,
      error: 'Device not found or offline'
    });
  }
});

module.exports = router;
