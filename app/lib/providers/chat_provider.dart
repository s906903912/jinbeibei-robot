import 'package:flutter/foundation.dart';
import '../services/api_service.dart';
import '../services/storage_service.dart';

/// 对话状态管理
class ChatProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();
  
  List<Map<String, dynamic>> _messages = [];
  bool _isLoading = false;
  
  List<Map<String, dynamic>> get messages => _messages;
  bool get isLoading => _isLoading;

  /// 加载对话历史
  Future<void> loadHistory(String deviceId) async {
    try {
      _messages = await _apiService.getChatHistory(deviceId);
      notifyListeners();
    } catch (e) {
      debugPrint('[ChatProvider] 加载历史失败: $e');
    }
  }

  /// 发送消息
  Future<void> sendMessage(String deviceId, String message) async {
    // 添加用户消息
    _messages.add({
      'role': 'user',
      'content': message,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    });
    notifyListeners();
    
    _isLoading = true;
    notifyListeners();
    
    try {
      final response = await _apiService.sendMessage(deviceId, message);
      
      // 添加 AI 回复
      _messages.add({
        'role': 'assistant',
        'content': response['reply'],
        'emotion': response['emotion'],
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      });
      
      // 保存到本地
      await StorageService.saveChatMessage(
        deviceId,
        'user',
        message,
      );
      await StorageService.saveChatMessage(
        deviceId,
        'assistant',
        response['reply'] as String,
        emotion: response['emotion'] as String?,
      );
    } catch (e) {
      debugPrint('[ChatProvider] 发送消息失败: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// 清空历史
  Future<void> clearHistory(String deviceId) async {
    try {
      await _apiService.clearChatHistory(deviceId);
      await StorageService.clearChatHistory(deviceId);
      _messages.clear();
      notifyListeners();
    } catch (e) {
      debugPrint('[ChatProvider] 清空历史失败: $e');
    }
  }
}
