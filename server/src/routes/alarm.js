/**
 * 闹钟管理 HTTP API
 */

const express = require('express');
const router = express.Router();

// 临时存储（后续替换为数据库）
const alarms = new Map();

// 获取闹钟列表
router.get('/', (req, res) => {
  const alarmList = Array.from(alarms.values());
  
  res.json({
    success: true,
    alarms: alarmList,
    timestamp: Date.now()
  });
});

// 获取单个闹钟
router.get('/:alarmId', (req, res) => {
  const { alarmId } = req.params;
  const alarm = alarms.get(alarmId);
  
  if (!alarm) {
    return res.status(404).json({
      success: false,
      error: 'Alarm not found'
    });
  }
  
  res.json({
    success: true,
    alarm,
    timestamp: Date.now()
  });
});

// 创建闹钟
router.post('/', (req, res) => {
  const { deviceId, time, enabled, repeat, label, sound } = req.body;
  
  if (!deviceId || !time) {
    return res.status(400).json({
      success: false,
      error: 'deviceId and time are required'
    });
  }
  
  const alarmId = `alarm_${Date.now()}_${Math.random().toString(36).substr(2, 9)}`;
  
  const alarm = {
    id: alarmId,
    deviceId,
    time,
    enabled: enabled !== false,
    repeat: repeat || ['everyday'],
    label: label || '',
    sound: sound || 'default',
    createdAt: Date.now(),
    updatedAt: Date.now()
  };
  
  alarms.set(alarmId, alarm);
  
  // TODO: 通知设备添加闹钟
  const { wss } = req.app.locals;
  if (wss) {
    wss.sendToDevice(deviceId, {
      type: 'add_alarm',
      data: alarm,
      timestamp: Date.now()
    });
  }
  
  res.json({
    success: true,
    alarm,
    message: 'Alarm created',
    timestamp: Date.now()
  });
});

// 更新闹钟
router.put('/:alarmId', (req, res) => {
  const { alarmId } = req.params;
  const alarm = alarms.get(alarmId);
  
  if (!alarm) {
    return res.status(404).json({
      success: false,
      error: 'Alarm not found'
    });
  }
  
  const { time, enabled, repeat, label, sound } = req.body;
  
  if (time) alarm.time = time;
  if (enabled !== undefined) alarm.enabled = enabled;
  if (repeat) alarm.repeat = repeat;
  if (label !== undefined) alarm.label = label;
  if (sound) alarm.sound = sound;
  
  alarm.updatedAt = Date.now();
  alarms.set(alarmId, alarm);
  
  // TODO: 通知设备更新闹钟
  const { wss } = req.app.locals;
  if (wss) {
    wss.sendToDevice(alarm.deviceId, {
      type: 'update_alarm',
      data: alarm,
      timestamp: Date.now()
    });
  }
  
  res.json({
    success: true,
    alarm,
    message: 'Alarm updated',
    timestamp: Date.now()
  });
});

// 删除闹钟
router.delete('/:alarmId', (req, res) => {
  const { alarmId } = req.params;
  const alarm = alarms.get(alarmId);
  
  if (!alarm) {
    return res.status(404).json({
      success: false,
      error: 'Alarm not found'
    });
  }
  
  const deviceId = alarm.deviceId;
  alarms.delete(alarmId);
  
  // TODO: 通知设备删除闹钟
  const { wss } = req.app.locals;
  if (wss) {
    wss.sendToDevice(deviceId, {
      type: 'delete_alarm',
      alarmId,
      timestamp: Date.now()
    });
  }
  
  res.json({
    success: true,
    message: 'Alarm deleted',
    timestamp: Date.now()
  });
});

// 启用/禁用闹钟
router.patch('/:alarmId/toggle', (req, res) => {
  const { alarmId } = req.params;
  const alarm = alarms.get(alarmId);
  
  if (!alarm) {
    return res.status(404).json({
      success: false,
      error: 'Alarm not found'
    });
  }
  
  alarm.enabled = !alarm.enabled;
  alarm.updatedAt = Date.now();
  alarms.set(alarmId, alarm);
  
  // TODO: 通知设备
  const { wss } = req.app.locals;
  if (wss) {
    wss.sendToDevice(alarm.deviceId, {
      type: 'toggle_alarm',
      alarmId,
      enabled: alarm.enabled,
      timestamp: Date.now()
    });
  }
  
  res.json({
    success: true,
    alarm,
    message: `Alarm ${alarm.enabled ? 'enabled' : 'disabled'}`,
    timestamp: Date.now()
  });
});

module.exports = router;
