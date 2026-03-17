# 金贝贝桌面精灵 - 项目总览

> 🐤 让你的桌面活起来！一个基于 ESP32-S3 的桌面机器人精灵

[![Version](https://img.shields.io/badge/version-0.1.0-blue.svg)](https://github.com/s906903912/jinbeibei-robot)
[![Platform](https://img.shields.io/badge/platform-ESP32--S3-orange.svg)](https://www.espressif.com/en/products/socs/esp32s3)
[![Flutter](https://img.shields.io/badge/Flutter-3.x-blue.svg)](https://flutter.dev/)
[![License](https://img.shields.io/badge/license-MIT-green.svg)](LICENSE)

## 📖 项目介绍

金贝贝是一个可爱的桌面小鸡精灵，拥有以下特点：

- 🎨 **可爱形象** - 4 寸屏幕上显示动态小鸡形象，会表达情绪
- 💬 **智能对话** - 接入 Qwen 大模型，可以和你聊天
- ⏰ **实用功能** - 闹钟、提醒、日程管理
- 📱 **手机控制** - Flutter APP 跨平台控制（iOS/Android）
- 🔌 **Type-C 供电** - 稳定供电，无需电池

## 🏗️ 系统架构

```
┌─────────────────────────────────────────────────────────┐
│                   金贝贝桌面精灵                         │
│                                                         │
│  ┌─────────────┐    ┌─────────────┐    ┌─────────────┐ │
│  │  移动端 APP  │───▶│  WebSocket  │───▶│  固件端     │ │
│  │  (Flutter)  │◀───│   服务器    │◀───│ (ESP32-S3)  │ │
│  │  iOS/Android│    │ (Node.js)   │    │  + 屏幕     │ │
│  └─────────────┘    └──────┬──────┘    └─────────────┘ │
│                            │                            │
│                            ▼                            │
│                     ┌─────────────┐                     │
│                     │  Qwen API   │                     │
│                     │ (大模型)    │                     │
│                     └─────────────┘                     │
└─────────────────────────────────────────────────────────┘
```

## 📁 项目结构

```
jinbeibei-robot/
├── README.md                 # 本文件
├── docs/                     # 文档
│   ├── app_architecture.md   # APP 架构设计
│   ├── server_architecture.md # 服务器架构设计
│   └── hardware/             # 硬件文档
├── firmware/                 # 固件代码 (ESP32-S3)
│   ├── src/
│   ├── platformio.ini
│   └── README.md
├── server/                   # WebSocket 服务器
│   ├── src/
│   ├── package.json
│   └── README.md
├── app/                      # Flutter 移动端 APP
│   ├── lib/
│   ├── pubspec.yaml
│   └── README.md
└── assets/                   # 资源文件
    ├── images/
    ├── animations/
    └── sounds/
```

## 🚀 快速开始

### 1. 硬件准备

**硬件清单：**
- ESP32-S3-DevKitC-1 (8MB PSRAM, Type-C) ×1
- 4 寸 IPS 触摸屏 800x480 (RGB 接口) ×1
- MAX98357 I2S 功放模块 ×1
- INMP441 数字麦克风 ×1
- 3W 4Ω 小喇叭 ×1
- Type-C 5V/2A 电源适配器 ×1

**采购链接：** 详见 [硬件采购指南](docs/hardware/shopping_guide.md)

### 2. 服务器部署

```bash
cd server
npm install
cp .env.example .env
# 编辑 .env 配置 Qwen API Key
npm run dev
```

详见 [服务器文档](server/README.md)

### 3. 固件烧录

```bash
cd firmware
# 安装 PlatformIO
pip install platformio
# 编译烧录
pio run --target upload
```

详见 [固件文档](firmware/README.md)

### 4. APP 安装

**iOS:**
```bash
cd app
flutter pub get
flutter run
```

**Android:**
```bash
cd app
flutter pub get
flutter run
```

详见 [APP 文档](app/README.md)

## 📱 功能特性

### 已实现 ✅

- [x] 项目架构设计
- [x] WebSocket 服务器框架
- [x] Flutter APP 框架
- [x] 设备管理 API
- [x] 闹钟管理 API
- [x] 对话聊天 API
- [x] 本地存储方案

### 开发中 🚧

- [ ] ESP32-S3 固件开发
- [ ] LVGL UI 实现
- [ ] APP 首页界面
- [ ] APP 对话界面
- [ ] 大模型集成

### 计划中 📋

- [ ] 语音识别
- [ ] 语音合成
- [ ] 多设备支持
- [ ] 云端同步
- [ ] 插件系统

## 🛠️ 技术栈

### 固件端
- **硬件**: ESP32-S3
- **框架**: Arduino / ESP-IDF
- **UI**: LVGL 8.x
- **开发工具**: PlatformIO

### 服务器端
- **语言**: Node.js
- **框架**: Express + ws
- **数据库**: SQLite (计划)
- **大模型**: Qwen API

### 移动端
- **框架**: Flutter 3.x
- **语言**: Dart
- **状态管理**: Provider
- **存储**: Hive

## 📖 文档索引

- [项目总览](README.md)
- [硬件指南](docs/hardware/)
  - [硬件清单](docs/hardware/shopping_guide.md)
  - [接线指南](docs/hardware/wiring.md)
- [服务器文档](server/README.md)
- [APP 文档](app/README.md)
- [固件文档](firmware/README.md)
- [API 文档](docs/api.md)

## 👥 项目成员

- **主人**: Auther
- **助手**: 哈基米 🐱

## 📝 开发日志

- **2026-03-17**: 项目启动，完成架构设计和代码框架
- 更多日志详见 [CHANGELOG.md](CHANGELOG.md)

## 🤝 贡献指南

欢迎贡献代码、文档或建议！

1. Fork 本项目
2. 创建特性分支 (`git checkout -b feature/AmazingFeature`)
3. 提交更改 (`git commit -m 'Add some AmazingFeature'`)
4. 推送到分支 (`git push origin feature/AmazingFeature`)
5. 提交 Pull Request

## 📄 开源协议

本项目采用 MIT 协议 - 详见 [LICENSE](LICENSE) 文件

## 🙏 致谢

感谢以下开源项目：

- [ESP32-S3](https://www.espressif.com/) - 强大的主控芯片
- [LVGL](https://lvgl.io/) - 轻量级图形库
- [Flutter](https://flutter.dev/) - 跨平台 UI 框架
- [Qwen](https://github.com/QwenLM/Qwen) - 通义千问大模型

## 📬 联系方式

- **项目地址**: https://github.com/s906903912/jinbeibei-robot
- **问题反馈**: https://github.com/s906903912/jinbeibei-robot/issues

---

**金贝贝桌面精灵 - 让你的桌面活起来！** 🐤✨

*Made with ❤️ by Auther & 哈基米*
