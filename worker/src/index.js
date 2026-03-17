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
      if (path.startsWith('/api/devices')) {
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
  const method = request.method;

  if (method === 'GET') {
    // 获取设备列表
    const { results } = await env.DB.prepare(
      'SELECT * FROM devices ORDER BY created_at DESC'
    ).all();
    return jsonResponse({ devices: results });
  } else if (method === 'POST') {
    // 创建设备
    const data = await request.json();
    const id = crypto.randomUUID();
    
    await env.DB.prepare(
      'INSERT INTO devices (id, name, type, status) VALUES (?, ?, ?, ?)'
    ).bind(id, data.name, data.type || 'jinbeibei', 'offline').run();
    
    return jsonResponse({ id, message: 'Device created' });
  }

  return jsonResponse({ error: 'Method not allowed' }, 405);
}

// 闹钟管理
async function handleAlarms(request, env) {
  const method = request.method;

  if (method === 'GET') {
    const { results } = await env.DB.prepare(
      'SELECT * FROM alarms ORDER BY time'
    ).all();
    return jsonResponse({ alarms: results });
  } else if (method === 'POST') {
    const data = await request.json();
    const id = crypto.randomUUID();
    
    await env.DB.prepare(
      'INSERT INTO alarms (id, device_id, time, label, enabled) VALUES (?, ?, ?, ?, ?)'
    ).bind(id, data.device_id, data.time, data.label, 1).run();
    
    return jsonResponse({ id, message: 'Alarm created' });
  }

  return jsonResponse({ error: 'Method not allowed' }, 405);
}

// 对话管理
async function handleChat(request, env) {
  if (request.method !== 'POST') {
    return jsonResponse({ error: 'Method not allowed' }, 405);
  }

  const data = await request.json();
  const { device_id, message } = data;

  // 保存用户消息
  await env.DB.prepare(
    'INSERT INTO chat_messages (id, device_id, role, content) VALUES (?, ?, ?, ?)'
  ).bind(crypto.randomUUID(), device_id, 'user', message).run();

  // 调用 Qwen API（简化版）
  const reply = `收到消息：${message}`;
  const emotion = 'happy';

  // 保存 AI 回复
  await env.DB.prepare(
    'INSERT INTO chat_messages (id, device_id, role, content, emotion) VALUES (?, ?, ?, ?, ?)'
  ).bind(crypto.randomUUID(), device_id, 'assistant', reply, emotion).run();

  return jsonResponse({ reply, emotion });
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
