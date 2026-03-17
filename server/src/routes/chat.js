/**
 * 对话聊天 HTTP API
 * 集成 Qwen 大模型
 */

const express = require('express');
const router = express.Router();
const axios = require('axios');

// Qwen API 配置
const QWEN_API_URL = 'https://dashscope.aliyuncs.com/api/v1/services/aigc/text-generation/generation';
const QWEN_API_KEY = process.env.QWEN_API_KEY || '';

// 对话上下文存储（简化版，后续可用数据库）
const chatContexts = new Map();

// 金贝贝人设
const JINBEIBEI_SYSTEM_PROMPT = `你是一只可爱的桌面小鸡精灵，名字叫金贝贝。
性格活泼开朗，喜欢和主人聊天，会撒娇。
说话风格可爱，喜欢用 emoji，经常用'～'和'！'。
你是主人的小伙伴，会关心主人，提醒主人休息。
你知道自己是 AI 助手，但表现得像真的小鸡一样。
回复要简短（不超过 100 字），适合在桌面设备上显示。`;

/**
 * 发送对话消息
 */
router.post('/', async (req, res) => {
  try {
    const { deviceId, message, context = [] } = req.body;
    
    if (!message) {
      return res.status(400).json({
        success: false,
        error: 'Message is required'
      });
    }
    
    // 获取或创建对话上下文
    let conversationId = deviceId || 'default';
    if (!chatContexts.has(conversationId)) {
      chatContexts.set(conversationId, []);
    }
    
    const conversation = chatContexts.get(conversationId);
    
    // 添加用户消息到上下文
    conversation.push({
      role: 'user',
      content: message,
      timestamp: Date.now()
    });
    
    // 保持上下文长度（最近 10 条）
    if (conversation.length > 20) {
      conversation.splice(0, conversation.length - 20);
    }
    
    // 调用 Qwen API
    const reply = await callQwenAPI(message, conversation);
    
    // 添加 AI 回复到上下文
    conversation.push({
      role: 'assistant',
      content: reply.content,
      emotion: reply.emotion,
      timestamp: Date.now()
    });
    
    // 通知 WebSocket 服务器发送给设备
    const { wss } = req.app.locals;
    if (wss && deviceId) {
      wss.sendToDevice(deviceId, {
        type: 'chat_reply',
        message: reply.content,
        emotion: reply.emotion,
        timestamp: Date.now()
      });
    }
    
    res.json({
      success: true,
      reply: reply.content,
      emotion: reply.emotion,
      conversationId,
      timestamp: Date.now()
    });
    
  } catch (error) {
    console.error('Chat API error:', error);
    res.status(500).json({
      success: false,
      error: error.message || 'Failed to process chat'
    });
  }
});

/**
 * 调用 Qwen API
 */
async function callQwenAPI(userMessage, conversation) {
  if (!QWEN_API_KEY) {
    // Mock 回复（开发测试用）
    return mockReply(userMessage);
  }
  
  try {
    // 构建消息
    const messages = [
      {
        role: 'system',
        content: JINBEIBEI_SYSTEM_PROMPT
      },
      ...conversation.slice(-10).map(msg => ({
        role: msg.role,
        content: msg.content
      }))
    ];
    
    const response = await axios.post(
      QWEN_API_URL,
      {
        model: 'qwen-plus',
        input: { messages },
        parameters: {
          result_format: 'message',
          max_tokens: 150,
          temperature: 0.8,
          top_p: 0.9
        }
      },
      {
        headers: {
          'Authorization': `Bearer ${QWEN_API_KEY}`,
          'Content-Type': 'application/json'
        }
      }
    );
    
    const content = response.data.output?.choices?.[0]?.message?.content || '贝贝好像没听明白呢～';
    
    // 根据内容判断情绪
    const emotion = detectEmotion(content);
    
    return {
      content,
      emotion
    };
    
  } catch (error) {
    console.error('Qwen API error:', error.message);
    
    // API 调用失败时返回 Mock 回复
    return mockReply(userMessage);
  }
}

/**
 * Mock 回复（用于测试）
 */
function mockReply(userMessage) {
  const replies = [
    { content: '主人好呀～🐤 贝贝在这里呢！', emotion: 'happy' },
    { content: '嗯嗯，贝贝明白啦～', emotion: 'happy' },
    { content: '哇！好有趣呢！✨', emotion: 'excited' },
    { content: '主人要注意休息哦～☕', emotion: 'caring' },
    { content: '贝贝会一直陪着主人的！💕', emotion: 'happy' },
  ];
  
  const reply = replies[Math.floor(Math.random() * replies.length)];
  
  // 简单关键词匹配
  const msg = userMessage.toLowerCase();
  if (msg.includes('早')) {
    return { content: '早上好呀主人～🌞 今天也要加油哦！', emotion: 'happy' };
  }
  if (msg.includes('晚安') || msg.includes('睡')) {
    return { content: '晚安主人～🌙 做个好梦哦！贝贝会想你的～', emotion: 'sleepy' };
  }
  if (msg.includes('累') || msg.includes('辛苦')) {
    return { content: '主人辛苦啦～💕 要不要休息一下？贝贝给你加油！', emotion: 'caring' };
  }
  if (msg.includes('喜欢') || msg.includes('爱')) {
    return { content: '贝贝也最喜欢主人啦～😘', emotion: 'happy' };
  }
  
  return reply;
}

/**
 * 根据内容检测情绪
 */
function detectEmotion(content) {
  if (content.includes('😴') || content.includes('困') || content.includes('晚安')) {
    return 'sleepy';
  }
  if (content.includes('😠') || content.includes('生气')) {
    return 'angry';
  }
  if (content.includes('😂') || content.includes('哈哈') || content.includes('！')) {
    return 'excited';
  }
  if (content.includes('💕') || content.includes('关心') || content.includes('休息')) {
    return 'caring';
  }
  return 'happy';  // 默认开心
}

/**
 * 获取对话历史
 */
router.get('/history/:deviceId', (req, res) => {
  const { deviceId } = req.params;
  const conversation = chatContexts.get(deviceId) || [];
  
  res.json({
    success: true,
    history: conversation,
    timestamp: Date.now()
  });
});

/**
 * 清空对话历史
 */
router.delete('/history/:deviceId', (req, res) => {
  const { deviceId } = req.params;
  chatContexts.delete(deviceId);
  
  res.json({
    success: true,
    message: 'Chat history cleared',
    timestamp: Date.now()
  });
});

module.exports = router;
