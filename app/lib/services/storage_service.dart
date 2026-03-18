import 'package:hive/hive.dart';
import 'package:flutter/foundation.dart';

/// 本地存储服务 - 使用 Hive 键值对数据库
class StorageService {
  static const String _deviceBoxName = 'devices';
  static const String _settingsBoxName = 'settings';
  static const String _chatBoxName = 'chat_history';
  
  static late Box<Map<String, dynamic>> _deviceBox;
  static late Box<Map<String, dynamic>> _settingsBox;
  static late Box<Map<String, dynamic>> _chatBox;
  
  static bool _initialized = false;
  
  /// 初始化存储
  static Future<void> init() async {
    if (_initialized) return;
    
    try {
      _deviceBox = await Hive.openBox<Map<String, dynamic>>(_deviceBoxName);
      _settingsBox = await Hive.openBox<Map<String, dynamic>>(_settingsBoxName);
      _chatBox = await Hive.openBox<Map<String, dynamic>>(_chatBoxName);
      
      _initialized = true;
      debugPrint('[Storage] 初始化完成');
    } catch (e) {
      debugPrint('[Storage] 初始化失败：$e');
      rethrow;
    }
  }
  
  // ==================== 设备管理 ====================
  
  /// 保存设备信息
  static Future<void> saveDevice(String deviceId, Map<String, dynamic> data) async {
    await _deviceBox.put(deviceId, data);
    debugPrint('[Storage] 设备已保存：$deviceId');
  }
  
  /// 获取设备信息
  static Map<String, dynamic>? getDevice(String deviceId) {
    return _deviceBox.get(deviceId);
  }
  
  /// 获取所有设备
  static List<Map<String, dynamic>> getAllDevices() {
    return _deviceBox.values.toList();
  }
  
  /// 删除设备
  static Future<void> deleteDevice(String deviceId) async {
    await _deviceBox.delete(deviceId);
    debugPrint('[Storage] 设备已删除：$deviceId');
  }
  
  /// 保存当前选中的设备 ID
  static Future<void> setCurrentDevice(String deviceId) async {
    await _settingsBox.put('current_device_id', {'id': deviceId});
  }
  
  /// 获取当前选中的设备 ID
  static String? getCurrentDevice() {
    final data = _settingsBox.get('current_device_id') as Map<String, dynamic>?;
    return data?['id'] as String?;
  }
  
  // ==================== 设置管理 ====================
  
  /// 保存设置
  static Future<void> saveSetting(String key, dynamic value) async {
    await _settingsBox.put(key, value);
    debugPrint('[Storage] 设置已保存：$key = $value');
  }
  
  /// 获取设置
  static T? getSetting<T>(String key, {T? defaultValue}) {
    final value = _settingsBox.get(key);
    return value as T? ?? defaultValue;
  }
  
  /// 保存服务器地址
  static Future<void> saveServerUrl(String url) async {
    await saveSetting('server_url', url);
  }
  
  /// 获取服务器地址
  static String? getServerUrl() {
    return getSetting<String>('server_url', defaultValue: 'http://localhost:8123');
  }
  
  /// 保存 WiFi 配置
  static Future<void> saveWifiConfig(String ssid, String password) async {
    await _settingsBox.put('wifi_config', {'ssid': ssid, 'password': password});
    debugPrint('[Storage] WiFi 配置已保存');
  }
  
  /// 获取 WiFi 配置
  static Map<String, String>? getWifiConfig() {
    final data = _settingsBox.get('wifi_config') as Map<String, dynamic>?;
    
    if (data == null) return null;
    
    return {
      'ssid': data['ssid'] as String,
      'password': data['password'] as String? ?? '',
    };
  }
  
  // ==================== 对话历史 ====================
  
  /// 保存对话消息
  static Future<void> saveChatMessage(
    String deviceId,
    String role,
    String content, {
    String? emotion,
  }) async {
    final key = '${deviceId}_${DateTime.now().millisecondsSinceEpoch}';
    await _chatBox.put(key, {
      'deviceId': deviceId,
      'role': role,
      'content': content,
      'emotion': emotion,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    });
  }
  
  /// 获取对话历史
  static List<Map<String, dynamic>> getChatHistory(String deviceId, {int limit = 50}) {
    final messages = _chatBox.values
        .where((m) => m['deviceId'] == deviceId)
        .toList();
    
    // 按时间排序
    messages.sort((a, b) => (b['timestamp'] as int).compareTo(a['timestamp'] as int));
    
    // 限制数量
    if (messages.length > limit) {
      messages.removeRange(limit, messages.length);
    }
    
    return messages;
  }
  
  /// 清空对话历史
  static Future<void> clearChatHistory(String deviceId) async {
    final keysToDelete = <String>[];
    
    for (final key in _chatBox.keys) {
      final value = _chatBox.get(key);
      if (value is Map<String, dynamic> && value['deviceId'] == deviceId) {
        keysToDelete.add(key);
      }
    }
    
    for (final key in keysToDelete) {
      await _chatBox.delete(key);
    }
    
    debugPrint('[Storage] 对话历史已清空：$deviceId');
  }
  
  // ==================== 通用操作 ====================
  
  /// 清空所有数据
  static Future<void> clearAll() async {
    await _deviceBox.clear();
    await _settingsBox.clear();
    await _chatBox.clear();
    debugPrint('[Storage] 所有数据已清空');
  }
  
  /// 导出备份
  static Future<Map<String, dynamic>> exportData() async {
    return {
      'devices': _deviceBox.toMap(),
      'settings': _settingsBox.toMap(),
      'chat_history': _chatBox.toMap(),
      'exported_at': DateTime.now().toIso8601String(),
    };
  }
  
  /// 导入备份
  static Future<void> importData(Map<String, dynamic> data) async {
    await clearAll();
    
    final devices = data['devices'] as Map<String, dynamic>?;
    if (devices != null) {
      devices.forEach((key, value) {
        _deviceBox.put(key, value as Map<String, dynamic>);
      });
    }
    
    final settings = data['settings'] as Map<String, dynamic>?;
    if (settings != null) {
      settings.forEach((key, value) {
        _settingsBox.put(key, value as Map<String, dynamic>);
      });
    }
    
    final chatHistory = data['chat_history'] as Map<String, dynamic>?;
    if (chatHistory != null) {
      chatHistory.forEach((key, value) {
        _chatBox.put(key, value as Map<String, dynamic>);
      });
    }
    
    debugPrint('[Storage] 数据已导入');
  }
}
