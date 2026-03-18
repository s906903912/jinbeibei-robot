/**
 * 金贝贝桌面精灵 - Cloudflare Worker API
 * 提供设备管理、对话、闹钟等 API
 */

export default {
  async fetch(request, env) {
    const url = new URL(request.url);
    const path = url.pathname;

    // CORS 处理
    if (request.method === 'OPTIONS') {
      return new Response(null, {
        headers: {
          'Access-Control-Allow-Origin': '*',
          'Access-Control-Allow-Methods': 'GET, POST, PUT, DELETE, OPTIONS',
          'Access-Control-Allow-Headers': 'Content-Type',
        },
      });
    }

    try {
      // 路由分发
      if (path === '/' || path === '') {
        return jsonResponse({
          name: '金贝贝桌面精灵 API',
          version: '1.0.0',
          endpoints: {
            health: '/api/health',
            devices: '/api/devices',
            alarms: '/api/alarms',
            chat: '/api/chat'
          }
        });
      } else if (path.startsWith('/api/devices')) {
        return handleDevices(request, env);
      } else if (path.startsWith('/api/alarms')) {
        return handleAlarms(request, env);
      } else if (path.startsWith('/api/chat')) {
        return handleChat(request, env);
      } else if (path === '/api/health') {
        return jsonResponse({ status: 'ok', timestamp: Date.now() });
      } else {
        return jsonResponse({ error: 'Not found' }, 404);
      }
    } catch (error) {
      return jsonResponse({ error: error.message }, 500);
    }
  },
};

// 设备管理
async function handleDevices(request, env) {
  const url = new URL(request.url);
  const path = url.pathname;
  const method = request.method;

  // GET /api/devices - 获取设备列表
  if (method === 'GET' && path === '/api/devices') {
    const { results } = await env.DB.prepare(
      'SELECT * FROM devices ORDER BY created_at DESC'
    ).all();
    return jsonResponse({ devices: results });
  }
  
  // GET /api/devices/:id - 获取单个设备
  const deviceMatch = path.match(/^\/api\/devices\/([^\/]+)$/);
  if (method === 'GET' && deviceMatch) {
    const deviceId = deviceMatch[1];
    const device = await env.DB.prepare(
      'SELECT * FROM devices WHERE id = ?'
    ).bind(deviceId).first();
    
    if (!device) {
      return jsonResponse({ error: 'Device not found' }, 404);
    }
    return jsonResponse({ device });
  }
  
  // POST /api/devices - 创建设备
  if (method === 'POST' && path === '/api/devices') {
    const data = await request.json();
    const id = crypto.randomUUID();
    
    await env.DB.prepare(
      'INSERT INTO devices (id, name, type, status) VALUES (?, ?, ?, ?)'
    ).bind(id, data.name, data.type || 'jinbeibei', 'offline').run();
    
    return jsonResponse({ id, message: 'Device created' });
  }
  
  // POST /api/devices/:id/control - 发送控制命令
  const controlMatch = path.match(/^\/api\/devices\/([^\/]+)\/control$/);
  if (method === 'POST' && controlMatch) {
    const deviceId = controlMatch[1];
    const { action, data } = await request.json();
    
    // 这里可以通过 WebSocket 或其他方式发送到设备
    // 暂时只记录日志
    return jsonResponse({ success: true, message: `Command sent: ${action}` });
  }
  
  // POST /api/devices/:id/emotion - 设置表情
  const emotionMatch = path.match(/^\/api\/devices\/([^\/]+)\/emotion$/);
  if (method === 'POST' && emotionMatch) {
    const deviceId = emotionMatch[1];
    const { emotion } = await request.json();
    
    await env.DB.prepare(
      'UPDATE devices SET emotion = ? WHERE id = ?'
    ).bind(emotion, deviceId).run();
    
    return jsonResponse({ success: true });
  }
  
  // POST /api/devices/:id/volume - 设置音量
  const volumeMatch = path.match(/^\/api\/devices\/([^\/]+)\/volume$/);
  if (method === 'POST' && volumeMatch) {
    const deviceId = volumeMatch[1];
    const { volume } = await request.json();
    
    await env.DB.prepare(
      'UPDATE devices SET volume = ? WHERE id = ?'
    ).bind(volume, deviceId).run();
    
    return jsonResponse({ success: true });
  }

  return jsonResponse({ error: 'Method not allowed' }, 405);
}

// 闹钟管理
async function handleAlarms(request, env) {
  const url = new URL(request.url);
  const path = url.pathname;
  const method = request.method;

  // GET /api/alarms - 获取闹钟列表
  if (method === 'GET' && path === '/api/alarms') {
    const { results } = await env.DB.prepare(
      'SELECT * FROM alarms ORDER BY time'
    ).all();
    return jsonResponse({ alarms: results });
  }
  
  // POST /api/alarms - 创建闹钟
  if (method === 'POST' && path === '/api/alarms') {
    const data = await request.json();
    const id = crypto.randomUUID();
    
    await env.DB.prepare(
      'INSERT INTO alarms (id, device_id, time, label, enabled, repeat, sound) VALUES (?, ?, ?, ?, ?, ?, ?)'
    ).bind(
      id, 
      data.deviceId, 
      data.time, 
      data.label || '', 
      data.enabled ? 1 : 0,
      JSON.stringify(data.repeat || []),
      data.sound || ''
    ).run();
    
    return jsonResponse({ alarm: { id, ...data } });
  }
  
  // PUT /api/alarms/:id - 更新闹钟
  const updateMatch = path.match(/^\/api\/alarms\/([^\/]+)$/);
  if (method === 'PUT' && updateMatch) {
    const alarmId = updateMatch[1];
    const data = await request.json();
    
    const updates = [];
    const values = [];
    
    if (data.time !== undefined) { updates.push('time = ?'); values.push(data.time); }
    if (data.enabled !== undefined) { updates.push('enabled = ?'); values.push(data.enabled ? 1 : 0); }
    if (data.label !== undefined) { updates.push('label = ?'); values.push(data.label); }
    if (data.repeat !== undefined) { updates.push('repeat = ?'); values.push(JSON.stringify(data.repeat)); }
    if (data.sound !== undefined) { updates.push('sound = ?'); values.push(data.sound); }
    
    if (updates.length > 0) {
      values.push(alarmId);
      await env.DB.prepare(
        `UPDATE alarms SET ${updates.join(', ')} WHERE id = ?`
      ).bind(...values).run();
    }
    
    return jsonResponse({ alarm: { id: alarmId, ...data } });
  }
  
  // DELETE /api/alarms/:id - 删除闹钟
  const deleteMatch = path.match(/^\/api\/alarms\/([^\/]+)$/);
  if (method === 'DELETE' && deleteMatch) {
    const alarmId = deleteMatch[1];
    await env.DB.prepare('DELETE FROM alarms WHERE id = ?').bind(alarmId).run();
    return jsonResponse({ success: true });
  }
  
  // PATCH /api/alarms/:id/toggle - 切换闹钟状态
  const toggleMatch = path.match(/^\/api\/alarms\/([^\/]+)\/toggle$/);
  if (method === 'PATCH' && toggleMatch) {
    const alarmId = toggleMatch[1];
    await env.DB.prepare(
      'UPDATE alarms SET enabled = NOT enabled WHERE id = ?'
    ).bind(alarmId).run();
    
    const alarm = await env.DB.prepare(
      'SELECT * FROM alarms WHERE id = ?'
    ).bind(alarmId).first();
    
    return jsonResponse({ alarm });
  }

  return jsonResponse({ error: 'Method not allowed' }, 405);
}

// 对话管理
async function handleChat(request, env) {
  const url = new URL(request.url);
  const path = url.pathname;
  const method = request.method;

  // POST /api/chat - 发送消息
  if (method === 'POST' && path === '/api/chat') {
    const data = await request.json();
    const { deviceId, message } = data;

    // 保存用户消息
    await env.DB.prepare(
      'INSERT INTO chat_messages (id, device_id, role, content) VALUES (?, ?, ?, ?)'
    ).bind(crypto.randomUUID(), deviceId, 'user', message).run();

    // 调用 Qwen API（简化版）
    const reply = `收到消息：${message}`;
    const emotion = 'happy';

    // 保存 AI 回复
    await env.DB.prepare(
      'INSERT INTO chat_messages (id, device_id, role, content, emotion) VALUES (?, ?, ?, ?, ?)'
    ).bind(crypto.randomUUID(), deviceId, 'assistant', reply, emotion).run();

    return jsonResponse({ reply, emotion });
  }
  
  // GET /api/chat/history/:deviceId - 获取对话历史
  const historyMatch = path.match(/^\/api\/chat\/history\/([^\/]+)$/);
  if (method === 'GET' && historyMatch) {
    const deviceId = historyMatch[1];
    const { results } = await env.DB.prepare(
      'SELECT * FROM chat_messages WHERE device_id = ? ORDER BY created_at DESC LIMIT 50'
    ).bind(deviceId).all();
    
    return jsonResponse({ history: results });
  }
  
  // DELETE /api/chat/history/:deviceId - 清空对话历史
  const clearMatch = path.match(/^\/api\/chat\/history\/([^\/]+)$/);
  if (method === 'DELETE' && clearMatch) {
    const deviceId = clearMatch[1];
    await env.DB.prepare(
      'DELETE FROM chat_messages WHERE device_id = ?'
    ).bind(deviceId).run();
    
    return jsonResponse({ success: true });
  }

  return jsonResponse({ error: 'Method not allowed' }, 405);
}

// JSON 响应辅助函数
function jsonResponse(data, status = 200) {
  return new Response(JSON.stringify(data), {
    status,
    headers: {
      'Content-Type': 'application/json',
      'Access-Control-Allow-Origin': '*',
    },
  });
}
