import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';

/// HTTP API 服务 - 与服务器 REST API 通信
class ApiService {
  String _baseUrl;
  
  ApiService({String baseUrl = 'https://jinbeibei-api.junxuanz.workers.dev'}) : _baseUrl = baseUrl;
  
  void updateBaseUrl(String url) {
    _baseUrl = url;
    debugPrint('[API] Base URL updated: $url');
  }
  
  String get baseUrl => _baseUrl;
  
  /// 通用 HTTP 请求
  Future<Map<String, dynamic>> _request(
    String method,
    String path, {
    Map<String, dynamic>? body,
  }) async {
    final url = Uri.parse('$_baseUrl$path');
    
    try {
      http.Response response;
      
      switch (method.toLowerCase()) {
        case 'get':
          response = await http.get(url);
          break;
        case 'post':
          response = await http.post(
            url,
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode(body),
          );
          break;
        case 'put':
          response = await http.put(
            url,
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode(body),
          );
          break;
        case 'delete':
          response = await http.delete(url);
          break;
        default:
          throw Exception('Unsupported HTTP method: $method');
      }
      
      if (response.statusCode >= 200 && response.statusCode < 300) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      } else {
        throw Exception('HTTP ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      debugPrint('[API] 请求失败：$e');
      rethrow;
    }
  }
  
  // ==================== 设备管理 ====================
  
  /// 获取设备列表
  Future<List<Map<String, dynamic>>> getDevices() async {
    final response = await _request('get', '/api/devices');
    final devices = response['devices'] as List? ?? [];
    return devices.map((d) => d as Map<String, dynamic>).toList();
  }
  
  /// 获取单个设备信息
  Future<Map<String, dynamic>> getDevice(String deviceId) async {
    final response = await _request('get', '/api/devices/$deviceId');
    return response['device'] as Map<String, dynamic>;
  }
  
  /// 发送控制命令
  Future<void> sendCommand(String deviceId, String action, Map<String, dynamic> data) async {
    await _request(
      'post',
      '/api/devices/$deviceId/control',
      body: {'action': action, 'data': data},
    );
  }
  
  /// 设置设备表情
  Future<void> setEmotion(String deviceId, String emotion) async {
    await _request(
      'post',
      '/api/devices/$deviceId/emotion',
      body: {'emotion': emotion},
    );
  }
  
  /// 设置设备音量
  Future<void> setVolume(String deviceId, int volume) async {
    await _request(
      'post',
      '/api/devices/$deviceId/volume',
      body: {'volume': volume},
    );
  }
  
  // ==================== 闹钟管理 ====================
  
  /// 获取闹钟列表
  Future<List<Map<String, dynamic>>> getAlarms() async {
    final response = await _request('get', '/api/alarms');
    final alarms = response['alarms'] as List? ?? [];
    return alarms.map((a) => a as Map<String, dynamic>).toList();
  }
  
  /// 创建闹钟
  Future<Map<String, dynamic>> createAlarm({
    required String deviceId,
    required String time,
    bool enabled = true,
    List<String>? repeat,
    String? label,
    String? sound,
  }) async {
    final response = await _request(
      'post',
      '/api/alarms',
      body: {
        'deviceId': deviceId,
        'time': time,
        'enabled': enabled,
        if (repeat != null) 'repeat': repeat,
        if (label != null) 'label': label,
        if (sound != null) 'sound': sound,
      },
    );
    return response['alarm'] as Map<String, dynamic>;
  }
  
  /// 更新闹钟
  Future<Map<String, dynamic>> updateAlarm(
    String alarmId, {
    String? time,
    bool? enabled,
    List<String>? repeat,
    String? label,
    String? sound,
  }) async {
    final body = <String, dynamic>{};
    if (time != null) body['time'] = time;
    if (enabled != null) body['enabled'] = enabled;
    if (repeat != null) body['repeat'] = repeat;
    if (label != null) body['label'] = label;
    if (sound != null) body['sound'] = sound;
    
    final response = await _request(
      'put',
      '/api/alarms/$alarmId',
      body: body,
    );
    return response['alarm'] as Map<String, dynamic>;
  }
  
  /// 删除闹钟
  Future<void> deleteAlarm(String alarmId) async {
    await _request('delete', '/api/alarms/$alarmId');
  }
  
  /// 切换闹钟启用状态
  Future<Map<String, dynamic>> toggleAlarm(String alarmId) async {
    final response = await _request('patch', '/api/alarms/$alarmId/toggle');
    return response['alarm'] as Map<String, dynamic>;
  }
  
  // ==================== 对话聊天 ====================
  
  /// 发送对话消息
  Future<Map<String, dynamic>> sendMessage(
    String deviceId,
    String message,
  ) async {
    final response = await _request(
      'post',
      '/api/chat',
      body: {
        'deviceId': deviceId,
        'message': message,
      },
    );
    return {
      'reply': response['reply'] as String,
      'emotion': response['emotion'] as String?,
    };
  }
  
  /// 获取对话历史
  Future<List<Map<String, dynamic>>> getChatHistory(String deviceId) async {
    final response = await _request('get', '/api/chat/history/$deviceId');
    final history = response['history'] as List? ?? [];
    return history.map((h) => h as Map<String, dynamic>).toList();
  }
  
  /// 清空对话历史
  Future<void> clearChatHistory(String deviceId) async {
    await _request('delete', '/api/chat/history/$deviceId');
  }
  
  // ==================== 健康检查 ====================
  
  /// 检查服务器健康状态
  Future<Map<String, dynamic>> healthCheck() async {
    return await _request('get', '/health');
  }
}
