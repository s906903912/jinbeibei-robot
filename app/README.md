# 金贝贝 APP

> 金贝贝桌面精灵的移动端控制应用 - Flutter 跨平台（iOS/Android）

## 📱 功能特性

- 🐤 **设备控制** - 实时查看设备状态，控制表情、音量
- 💬 **智能对话** - 与金贝贝文字/语音聊天
- ⏰ **闹钟管理** - 设置、编辑、删除闹钟
- 🎨 **表情互动** - 切换金贝贝的情绪状态
- 📡 **实时连接** - WebSocket 保持设备与手机通信

## 🚀 快速开始

### 环境要求

- Flutter 3.x
- Dart 3.x
- iOS 12+ / Android 5.0+

### 安装依赖

```bash
cd app
flutter pub get
```

### 运行应用

**iOS 模拟器**
```bash
flutter run
```

**Android 模拟器**
```bash
flutter run
```

**真机调试**
```bash
flutter run -d <device_id>
```

### 构建发布

**iOS**
```bash
flutter build ios
```

**Android APK**
```bash
flutter build apk --release
```

**Android App Bundle**
```bash
flutter build appbundle --release
```

## 📁 项目结构

```
app/
├── lib/
│   ├── main.dart              # 应用入口
│   ├── config/
│   │   ├── routes.dart        # 路由配置
│   │   └── theme.dart         # 主题配置
│   ├── models/
│   │   ├── device.dart        # 设备模型
│   │   ├── message.dart       # 消息模型
│   │   └── alarm.dart         # 闹钟模型
│   ├── services/
│   │   ├── websocket_service.dart  # WebSocket 服务
│   │   ├── api_service.dart        # HTTP API 服务
│   │   └── storage_service.dart    # 本地存储
│   ├── providers/
│   │   ├── device_provider.dart    # 设备状态管理
│   │   ├── chat_provider.dart      # 对话状态管理
│   │   └── alarm_provider.dart     # 闹钟状态管理
│   ├── screens/
│   │   ├── home/                   # 首页
│   │   ├── chat/                   # 对话页
│   │   ├── alarm/                  # 闹钟页
│   │   └── settings/               # 设置页
│   └── widgets/
│       ├── jinbeibei_avatar.dart   # 金贝贝形象
│       └── ...
├── assets/
│   ├── images/                     # 图片资源
│   ├── animations/                 # 动画文件
│   └── sounds/                     # 音效文件
└── pubspec.yaml                    # 依赖配置
```

## 🎨 核心页面

### 首页（设备控制）

显示金贝贝形象、设备状态、快捷功能入口

### 对话页

与金贝贝聊天，支持文字和语音输入

### 闹钟页

管理闹钟列表，添加/编辑/删除闹钟

### 设置页

WiFi 配置、音量调节、关于页面

## 🔌 WebSocket 连接

### 连接服务器

```dart
final service = WebSocketService();
await service.connect('ws://192.168.1.100:8123');
```

### 发送消息

```dart
// 控制设备
service.sendCommand('set_emotion', {'emotion': 'happy'});

// 发送对话
service.sendChatMessage('你好呀');
```

### 接收消息

```dart
service.messageStream.listen((message) {
  switch (message['type']) {
    case 'device_status':
      // 设备状态更新
      break;
    case 'chat_reply':
      // 收到回复
      break;
  }
});
```

## 📦 依赖说明

### 状态管理
- **provider** - 简单的状态管理方案

### 网络通信
- **web_socket_channel** - WebSocket 连接
- **http** - HTTP API 调用

### 本地存储
- **hive** - 快速键值对存储
- **shared_preferences** - 简单配置存储

### UI 组件
- **flutter_animate** - 动画效果
- **lottie** - 动画文件播放

### 语音功能
- **flutter_tts** - 文字转语音
- **speech_to_text** - 语音识别

## 🐛 常见问题

### iOS 构建失败

确保 `ios/Podfile` 中设置了最低版本：
```ruby
platform :ios, '12.0'
```

### Android 网络权限

在 `AndroidManifest.xml` 中添加：
```xml
<uses-permission android:name="android.permission.INTERNET"/>
```

### WebSocket 连接失败

检查：
1. 服务器是否运行
2. IP 地址是否正确
3. 防火墙是否阻止

## 📝 开发计划

**v0.1.0 (MVP)**
- [x] 项目框架搭建
- [ ] 设备连接与发现
- [ ] 基础对话功能
- [ ] 表情切换
- [ ] 闹钟管理

**v0.2.0**
- [ ] 语音输入/输出
- [ ] 多设备支持
- [ ] 对话历史记录

**v1.0.0**
- [ ] 主题切换
- [ ] 云端同步
- [ ] 插件系统

## 🔗 相关资源

- [Flutter 官方文档](https://flutter.dev/docs)
- [Provider 文档](https://pub.dev/packages/provider)
- [金贝贝服务器文档](../server/README.md)

---

*金贝贝 APP - 让手机成为金贝贝的遥控器！* 📱🐤
