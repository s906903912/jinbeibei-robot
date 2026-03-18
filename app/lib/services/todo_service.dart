import 'package:flutter/foundation.dart';
import 'storage_service.dart';

/// 待办事项服务
class TodoService {
  /// 添加待办
  static Future<void> addTodo(String title, {String? dueTime}) async {
    final todos = await getTodos();
    todos.add({
      'id': DateTime.now().millisecondsSinceEpoch.toString(),
      'title': title,
      'completed': false,
      'createdAt': DateTime.now().toIso8601String(),
      if (dueTime != null) 'dueTime': dueTime,
    });
    await StorageService.saveSetting('todos', todos);
    debugPrint('[Todo] 添加待办：$title');
  }
  
  /// 获取待办列表
  static Future<List<Map<String, dynamic>>> getTodos() async {
    final data = StorageService.getSetting<List>('todos', defaultValue: []);
    return data!.map((e) => e as Map<String, dynamic>).toList();
  }
  
  /// 完成待办
  static Future<void> completeTodo(String id) async {
    final todos = await getTodos();
    final index = todos.indexWhere((t) => t['id'] == id);
    if (index != -1) {
      todos[index]['completed'] = true;
      await StorageService.saveSetting('todos', todos);
    }
  }
  
  /// 删除待办
  static Future<void> deleteTodo(String id) async {
    final todos = await getTodos();
    todos.removeWhere((t) => t['id'] == id);
    await StorageService.saveSetting('todos', todos);
  }
}
