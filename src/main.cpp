/**
 * 金贝贝桌面精灵 - 主程序
 * JinBeibei Desktop Pet - Main Entry
 * 
 * @author Auther & 哈基米
 * @version 0.1.0
 * @date 2026-03-17
 */

#include <Arduino.h>
#include <WiFi.h>
#include <lvgl.h>
#include <driver/i2s.h>

// 项目配置
#include "config.h"

// UI 模块
#include "ui/jinbeibei_ui.h"

// 网络模块
#include "network/wifi_manager.h"
#include "network/feishu_bot.h"

// 音频模块
#include "audio/audio_player.h"
#include "audio/mic_recorder.h"

// 功能模块
#include "skills/alarm_clock.h"
#include "skills/chat_handler.h"

// ==================== 全局对象 ====================

// UI 相关
static lv_disp_t* disp = nullptr;
static lv_obj_t* jinbeibei_avatar = nullptr;

// 网络相关
static WiFiManager wifi_mgr;
static FeishuBot feishu_bot;

// 音频相关
static AudioPlayer audio_player;
static MicRecorder mic_recorder;

// 功能相关
static AlarmClock alarm_clock;
static ChatHandler chat_handler;

// 状态管理
enum DeviceState {
    STATE_BOOTING,      // 启动中
    STATE_IDLE,         // 空闲（眨眼动画）
    STATE_LISTENING,    // 聆听中
    STATE_THINKING,     // 思考中
    STATE_SPEAKING,     // 说话中
    STATE_SLEEPING,     // 睡眠模式
};

static DeviceState current_state = STATE_BOOTING;
static unsigned long last_activity_time = 0;
static const unsigned long SLEEP_TIMEOUT = 300000;  // 5 分钟无操作进入睡眠

// ==================== 回调函数 ====================

/**
 * WiFi 连接成功回调
 */
void on_wifi_connected() {
    Serial.println("[INFO] WiFi 连接成功！");
    Serial.print("[INFO] IP 地址：");
    Serial.println(WiFi.localIP());
    
    // 更新 UI 状态
    jinbeibei_ui_set_network_status(true);
    
    // 连接飞书机器人
    feishu_bot.begin();
}

/**
 * WiFi 断开回调
 */
void on_wifi_disconnected() {
    Serial.println("[INFO] WiFi 断开");
    jinbeibei_ui_set_network_status(false);
}

/**
 * 收到飞书消息回调
 */
void on_feishu_message(const String& message, const String& sender) {
    Serial.printf("[FEISHU] 收到消息：%s (来自：%s)\n", message.c_str(), sender.c_str());
    
    // 切换到思考状态
    current_state = STATE_THINKING;
    jinbeibei_ui_set_emotion("thinking");
    
    // 调用大模型处理
    chat_handler.handle_message(message, [](const String& reply) {
        // 回复回调
        current_state = STATE_SPEAKING;
        jinbeibei_ui_set_emotion("speaking");
        
        // 发送回复到飞书
        feishu_bot.send_message(reply);
        
        // 语音播放（如果有 TTS）
        audio_player.speak(reply);
        
        // 恢复空闲状态
        current_state = STATE_IDLE;
        jinbeibei_ui_set_emotion("happy");
        last_activity_time = millis();
    });
}

// ==================== 初始化函数 ====================

/**
 * 初始化串口
 */
void init_serial() {
    Serial.begin(115200);
    Serial.setDebugOutput(true);
    delay(1000);
    
    Serial.println();
    Serial.println("╔════════════════════════════════════════╗");
    Serial.println("║     金贝贝桌面精灵 - JinBeibei         ║");
    Serial.println("║          Version 0.1.0                 ║");
    Serial.println("║      🐤 Let's make desk fun! 🐤       ║");
    Serial.println("╚════════════════════════════════════════╝");
    Serial.println();
}

/**
 * 初始化 LVGL UI
 */
void init_lvgl() {
    Serial.println("[INIT] 初始化 LVGL...");
    
    lv_init();
    
    // 初始化显示屏驱动（需要根据实际屏幕调整）
    // TODO: 实现具体的屏幕驱动初始化
    
    // 创建金贝贝 UI
    jinbeibei_avatar = jinbeibei_ui_create_avatar();
    
    // 设置初始表情
    jinbeibei_ui_set_emotion("happy");
    
    Serial.println("[INIT] LVGL 初始化完成");
}

/**
 * 初始化 WiFi
 */
void init_wifi() {
    Serial.println("[INIT] 初始化 WiFi...");
    
    wifi_mgr.begin(WIFI_SSID, WIFI_PASSWORD);
    wifi_mgr.on_connected(on_wifi_connected);
    wifi_mgr.on_disconnected(on_wifi_disconnected);
    
    Serial.println("[INIT] WiFi 初始化完成");
}

/**
 * 初始化音频
 */
void init_audio() {
    Serial.println("[INIT] 初始化音频...");
    
    audio_player.begin();
    mic_recorder.begin();
    
    // 播放启动音效
    audio_player.play_sound("boot");
    
    Serial.println("[INIT] 音频初始化完成");
}

/**
 * 初始化功能模块
 */
void init_skills() {
    Serial.println("[INIT] 初始化功能模块...");
    
    alarm_clock.begin();
    chat_handler.begin();
    
    Serial.println("[INIT] 功能模块初始化完成");
}

// ==================== 主循环 ====================

/**
 * 处理状态机
 */
void handle_state_machine() {
    unsigned long current_time = millis();
    
    switch (current_state) {
        case STATE_BOOTING:
            // 启动完成后切换到空闲
            current_state = STATE_IDLE;
            jinbeibei_ui_set_emotion("happy");
            last_activity_time = current_time;
            break;
            
        case STATE_IDLE:
            // 检测是否超时进入睡眠
            if (current_time - last_activity_time > SLEEP_TIMEOUT) {
                current_state = STATE_SLEEPING;
                jinbeibei_ui_set_emotion("sleepy");
            }
            // 播放空闲动画（眨眼等）
            jinbeibei_ui_update_idle_animation();
            break;
            
        case STATE_LISTENING:
            // 监听语音输入
            if (mic_recorder.detect_wake_word()) {
                current_state = STATE_THINKING;
                jinbeibei_ui_set_emotion("thinking");
            }
            break;
            
        case STATE_THINKING:
            // 等待 chat_handler 回调处理
            break;
            
        case STATE_SPEAKING:
            // 等待音频播放完成
            if (!audio_player.is_playing()) {
                current_state = STATE_IDLE;
                jinbeibei_ui_set_emotion("happy");
                last_activity_time = millis();
            }
            break;
            
        case STATE_SLEEPING:
            // 检测是否被唤醒（触摸、声音等）
            if (jinbeibei_ui_detect_wake_up()) {
                current_state = STATE_IDLE;
                jinbeibei_ui_set_emotion("happy");
                last_activity_time = millis();
            }
            break;
    }
}

/**
 * 处理网络事件
 */
void handle_network() {
    wifi_mgr.loop();
    feishu_bot.loop();
}

/**
 * 处理 UI 更新
 */
void handle_ui() {
    // LVGL 任务处理（需要定期调用）
    lv_timer_handler();
    delay(5);
}

/**
 * 主循环
 */
void loop() {
    // 处理状态机
    handle_state_machine();
    
    // 处理网络
    handle_network();
    
    // 处理 UI
    handle_ui();
    
    // 小延迟，避免 CPU 占用过高
    delay(10);
}

// ==================== Arduino 入口 ====================

void setup() {
    // 初始化串口
    init_serial();
    
    // 初始化 UI
    init_lvgl();
    
    // 初始化 WiFi
    init_wifi();
    
    // 初始化音频
    init_audio();
    
    // 初始化功能模块
    init_skills();
    
    Serial.println();
    Serial.println("[SYSTEM] 系统初始化完成！");
    Serial.println("[SYSTEM] 金贝贝准备就绪！🐤");
    Serial.println();
}
