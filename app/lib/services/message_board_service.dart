import 'package:flutter/foundation.dart';
import 'storage_service.dart';

/// 留言板服务
class MessageBoardService {
  /// 添加留言
  static Future<void> addMessage(String author, String content) async {
    final messages = await getMessages();
    messages.insert(0, {
      'id': DateTime.now().millisecondsSinceEpoch.toString(),
      'author': author,
      'content': content,
      'createdAt': DateTime.now().toIso8601String(),
    });
    await StorageService.saveSetting('messages', messages);
    debugPrint('[MessageBoard] 添加留言：$author - $content');
  }
  
  /// 获取留言列表
  static Future<List<Map<String, dynamic>>> getMessages() async {
    final data = StorageService.getSetting<List>('messages', defaultValue: []);
    return data!.map((e) => e as Map<String, dynamic>).toList();
  }
  
  /// 删除留言
  static Future<void> deleteMessage(String id) async {
    final messages = await getMessages();
    messages.removeWhere((m) => m['id'] == id);
    await StorageService.saveSetting('messages', messages);
  }
}
