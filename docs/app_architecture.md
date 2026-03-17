# 金贝贝 APP - 移动端应用架构

## 📱 技术选型

**框架**: Flutter 3.x
- ✅ 跨平台（iOS + Android 一套代码）
- ✅ 热重载，开发效率高
- ✅ 丰富的 UI 组件
- ✅ 性能接近原生

**状态管理**: Provider / Riverpod
**网络通信**: WebSocket + HTTP
**本地存储**: Hive / SharedPreferences
**语音功能**: flutter_tts (TTS) + speech_to_text

## 🏗️ APP 架构

```
lib/
├── main.dart                 # 应用入口
├── config/                   # 配置
│   ├── routes.dart          # 路由配置
│   └── theme.dart           # 主题配置
├── models/                   # 数据模型
│   ├── device.dart          # 设备模型
│   ├── message.dart         # 消息模型
│   └── alarm.dart           # 闹钟模型
├── services/                 # 服务层
│   ├── websocket_service.dart  # WebSocket 连接
│   ├── api_service.dart        # HTTP API
│   └── storage_service.dart    # 本地存储
├── providers/                # 状态管理
│   ├── device_provider.dart
│   ├── chat_provider.dart
│   └── alarm_provider.dart
├── screens/                  # 页面
│   ├── home/                # 首页（设备控制）
│   ├── chat/                # 对话页面
│   ├── alarm/               # 闹钟设置
│   ├── settings/            # 设置页面
│   └── device/              # 设备配对
├── widgets/                  # 组件
│   ├── jinbeibei_avatar.dart   # 金贝贝形象
│   ├── chat_bubble.dart        # 聊天气泡
│   └── emotion_selector.dart   # 表情选择器
└── utils/                    # 工具类
    ├── constants.dart
    └── helpers.dart
```

## 🎨 核心页面设计

### 1. 首页（设备控制）

```
┌─────────────────────────────┐
│  ← 金贝贝桌面精灵           │
├─────────────────────────────┤
│                             │
│      🐤                     │
│   (金贝贝动态形象)          │
│                             │
│   [开心] [生气] [困倦]      │
│   (快速表情切换)            │
│                             │
├─────────────────────────────┤
│  💬 对话  ⏰ 闹钟  🎵 音乐  │
│  (功能快捷入口)             │
├─────────────────────────────┤
│  设备状态：🟢 在线          │
│  电量：🔌 充电中            │
│  音量：███████░ 70%         │
└─────────────────────────────┘
```

### 2. 对话页面

```
┌─────────────────────────────┐
│  ← 和金贝贝聊天             │
├─────────────────────────────┤
│                             │
│  [金贝贝] 主人好呀～🐤      │
│  (左侧气泡，带头像)         │
│                             │
│        今天天气不错哦！     │
│        (右侧气泡)           │
│                             │
│  [金贝贝] 对呀～适合出去玩  │
│                             │
├─────────────────────────────┤
│  [🎤] 输入消息...    [发送] │
│  (语音 + 文字输入)          │
└─────────────────────────────┘
```

### 3. 闹钟设置

```
┌─────────────────────────────┐
│  ← 闹钟管理           [+添加]│
├─────────────────────────────┤
│                             │
│  ⏰ 07:30  起床啦！         │
│     每天        ✅ 启用     │
│  ─────────────────────────  │
│                             │
│  ⏰ 09:00  该休息啦～       │
│     工作日      ✅ 启用     │
│  ─────────────────────────  │
│                             │
│  ⏰ 23:00  晚安哦🌙         │
│     每天        ❌ 禁用     │
│                             │
└─────────────────────────────┘
```

## 🔌 WebSocket 通信协议

### 连接建立

```dart
// 连接到金贝贝设备
final ws = WebSocketService();
await ws.connect('ws://192.168.1.100:8123');
```

### 消息格式

**APP → 设备**
```json
{
  "type": "command",
  "action": "set_emotion",
  "data": {
    "emotion": "happy"
  },
  "timestamp": 1710669600000
}
```

**设备 → APP**
```json
{
  "type": "event",
  "event": "emotion_changed",
  "data": {
    "emotion": "happy",
    "duration": 3000
  },
  "timestamp": 1710669600000
}
```

### 支持的操作

| 操作 | 方向 | 说明 |
|------|------|------|
| `set_emotion` | APP→设备 | 设置表情 |
| `send_message` | APP→设备 | 发送对话消息 |
| `add_alarm` | APP→设备 | 添加闹钟 |
| `delete_alarm` | APP→设备 | 删除闹钟 |
| `set_volume` | APP→设备 | 调节音量 |
| `device_status` | 设备→APP | 设备状态上报 |
| `alarm_triggered` | 设备→APP | 闹钟触发通知 |
| `message_reply` | 设备→APP | 对话回复 |

## 📦 依赖包

```yaml
dependencies:
  flutter:
    sdk: flutter
  
  # 状态管理
  provider: ^6.1.1
  # 或 riverpod: ^2.4.9
  
  # 网络
  web_socket_channel: ^2.4.0
  http: ^1.1.0
  
  # 本地存储
  hive: ^2.2.3
  hive_flutter: ^1.1.0
  shared_preferences: ^2.2.2
  
  # UI
  flutter_animate: ^4.3.0
  lottie: ^2.7.0  # 动画
  
  # 语音
  flutter_tts: ^3.8.3
  speech_to_text: ^6.3.0
  
  # 工具
  uuid: ^4.2.1
  intl: ^0.18.1
```

## 🚀 开发步骤

### 1. 创建 Flutter 项目
```bash
flutter create jinbeibei_app
cd jinbeibei_app
```

### 2. 添加依赖
编辑 `pubspec.yaml`

### 3. 实现核心服务
- WebSocket 连接管理
- 设备发现与配对
- 消息收发

### 4. 实现 UI 页面
- 首页（设备控制）
- 对话页面
- 闹钟管理

### 5. 测试与优化
- 真机测试
- 性能优化
- UI 美化

## 🎯 MVP 功能清单

**第一版本（MVP）必须实现：**
- [ ] 设备配对（同一 WiFi 下自动发现）
- [ ] 基础对话（文字）
- [ ] 表情切换
- [ ] 闹钟设置/删除
- [ ] 音量调节

**后续版本：**
- [ ] 语音输入/输出
- [ ] 多设备管理
- [ ] 主题切换
- [ ] 云端同步
- [ ] 插件系统（天气、新闻等）

---

*金贝贝 APP - 让手机成为金贝贝的遥控器！* 📱🐤
