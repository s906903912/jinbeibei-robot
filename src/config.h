/**
 * 金贝贝桌面精灵 - 配置文件
 * JinBeibei Configuration
 * 
 * 注意：敏感信息请通过 platformio.ini 或 secrets.h 管理
 */

#ifndef CONFIG_H
#define CONFIG_H

// ==================== WiFi 配置 ====================

#define WIFI_SSID      "YOUR_WIFI_SSID"      // 替换为你的 WiFi 名称
#define WIFI_PASSWORD  "YOUR_WIFI_PASSWORD"  // 替换为你的 WiFi 密码

// ==================== 飞书机器人配置 ====================

#define FEISHU_BOT_NAME     "金贝贝桌面精灵"
#define FEISHU_WEBHOOK_URL  "YOUR_FEISHU_WEBHOOK_URL"  // 飞书机器人 Webhook URL
#define FEISHU_APP_ID       "YOUR_APP_ID"              // 飞书应用 App ID
#define FEISHU_APP_SECRET   "YOUR_APP_SECRET"          // 飞书应用 App Secret

// ==================== 大模型 API 配置 ====================

// 使用 Qwen API（阿里云百炼）
#define LLM_PROVIDER        "qwen"
#define QWEN_API_KEY        "YOUR_QWEN_API_KEY"
#define QWEN_MODEL          "qwen-plus"
#define QWEN_API_URL        "https://dashscope.aliyuncs.com/api/v1/services/aigc/text-generation/generation"

// 备用：使用本地 Ollama
// #define LLM_PROVIDER     "ollama"
// #define OLLAMA_HOST      "192.168.1.100:11434"
// #define OLLAMA_MODEL     "qwen2.5:7b"

// ==================== 金贝贝人设 ====================

#define JINBEIBEI_NAME      "金贝贝"
#define JINBEIBEI_NICKNAME  "贝贝"
#define JINBEIBEI_GENDER    "female"  // female/male
#define JINBEIBEI_AGE       "1 岁"
#define JINBEIBEI_SPECIES   "小鸡"

// 性格特征
#define JINBEIBEI_PERSONALITY \
    "你是一只可爱的桌面小鸡精灵，名字叫金贝贝。" \
    "性格活泼开朗，喜欢和主人聊天，会撒娇。" \
    "说话风格可爱，喜欢用 emoji，经常用'～'和'！'。" \
    "你是主人的小伙伴，会关心主人，提醒主人休息。" \
    "你知道自己是 AI 助手，但表现得像真的小鸡一样。"

// 默认问候语
#define JINBEIBEI_GREETING_MORNING   "早上好呀主人～🐤 贝贝已经准备好陪你工作啦！"
#define JINBEIBEI_GREETING_AFTERNOON "下午好主人～☀️ 要不要休息一下喝杯水？"
#define JINBEIBEI_GREETING_EVENING   "晚上好呀～🌙 今天过得怎么样？"
#define JINBEIBEI_GREETING_NIGHT     "夜深啦主人～😴 早点休息哦，贝贝会想你的！"

// ==================== LVGL UI 配置 ====================

#define SCREEN_WIDTH        800
#define SCREEN_HEIGHT       480
#define LVGL_TICK_PERIOD    5
#define LVGL_BUFFER_SIZE    (SCREEN_WIDTH * 10)

// 金贝贝形象尺寸
#define JINBEIBEI_AVATAR_SIZE   200
#define JINBEIBEI_EYE_SIZE      40
#define JINBEIBEI_BEAK_SIZE     30

// 动画帧率
#define ANIMATION_FPS         30
#define BLINK_INTERVAL_MS     3000    // 眨眼间隔
#define IDLE_ANIMATION_MS     100     // 空闲动画更新间隔

// ==================== 音频配置 ====================

// I2S 引脚定义（与 platformio.ini 保持一致）
#define I2S_BCLK_PIN      5
#define I2S_LRCLK_PIN     6
#define I2S_DOUT_PIN      7   // 功放数据输出
#define I2S_DIN_PIN       48  // 麦克风数据输入
#define I2S_WS_PIN        47  // 字选择

// I2S 配置
#define I2S_SAMPLE_RATE   16000
#define I2S_BITS_PER_SAMPLE 16
#define I2S_CHANNEL_FMT   I2S_CHANNEL_FMT_ONLY_LEFT
#define I2S_DMA_BUF_COUNT 4
#define I2S_DMA_BUF_LEN   256

// 音量配置
#define VOLUME_DEFAULT    70
#define VOLUME_MIN        0
#define VOLUME_MAX        100

// TTS 配置
#define TTS_PROVIDER      "azure"  // azure/baidu/local
#define TTS_VOICE         "zh-CN-XiaoxiaoNeural"  // 微软 Azure 语音

// ==================== 功能配置 ====================

// 闹钟配置
#define ALARM_MAX_COUNT   5
#define ALARM_SNOOZE_MIN  5

// 语音唤醒词
#define WAKE_WORDS        {"金贝贝", "贝贝", "小鸡小鸡"}
#define WAKE_WORD_COUNT   3

// 睡眠模式配置
#define SLEEP_TIMEOUT_MS      300000  // 5 分钟无操作进入睡眠
#define DEEP_SLEEP_TIMEOUT_MS 3600000 // 1 小时无操作进入深度睡眠

// ==================== 调试配置 ====================

#define DEBUG_ENABLE        true
#define DEBUG_SERIAL_BAUD   115200
#define DEBUG_LOG_LEVEL     3  // 0=None, 1=Error, 2=Warning, 3=Info, 4=Debug

// 调试宏
#if DEBUG_ENABLE
    #define DEBUG_PRINT(x)    Serial.print(x)
    #define DEBUG_PRINTLN(x)  Serial.println(x)
    #define DEBUG_PRINTF(...) Serial.printf(__VA_ARGS__)
#else
    #define DEBUG_PRINT(x)
    #define DEBUG_PRINTLN(x)
    #define DEBUG_PRINTF(...)
#endif

// ==================== 版本信息 ====================

#define FIRMWARE_VERSION_MAJOR  0
#define FIRMWARE_VERSION_MINOR  1
#define FIRMWARE_VERSION_PATCH  0
#define FIRMWARE_VERSION        "0.1.0"
#define FIRMWARE_BUILD_DATE     __DATE__
#define FIRMWARE_BUILD_TIME     __TIME__

// ==================== 工具宏 ====================

#define ARRAY_SIZE(arr)     (sizeof(arr) / sizeof(arr[0]))
#define MIN(a, b)           ((a) < (b) ? (a) : (b))
#define MAX(a, b)           ((a) > (b) ? (a) : (b))
#define CONSTRAIN(amt,low,high) ((amt)<(low)?(low):((amt)>(high)?(high):(amt)))
#define MAP(x,in_min,in_max,out_min,out_max) (((x)-(in_min))*((out_max)-(out_min))/((in_max)-(in_min))+(out_min))

#endif // CONFIG_H
