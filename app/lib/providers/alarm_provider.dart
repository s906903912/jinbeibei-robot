import 'package:flutter/foundation.dart';
import '../services/api_service.dart';

/// 闹钟状态管理
class AlarmProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();
  
  List<Map<String, dynamic>> _alarms = [];
  
  List<Map<String, dynamic>> get alarms => _alarms;

  /// 加载闹钟列表
  Future<void> loadAlarms(String deviceId) async {
    try {
      _alarms = await _apiService.getAlarms();
      notifyListeners();
    } catch (e) {
      debugPrint('[AlarmProvider] 加载闹钟失败: $e');
    }
  }

  /// 切换闹钟启用状态
  Future<void> toggleAlarm(String alarmId) async {
    try {
      await _apiService.toggleAlarm(alarmId);
      
      // 更新本地状态
      final index = _alarms.indexWhere((a) => a['id'] == alarmId);
      if (index != -1) {
        _alarms[index]['enabled'] = !(_alarms[index]['enabled'] as bool);
        notifyListeners();
      }
    } catch (e) {
      debugPrint('[AlarmProvider] 切换闹钟失败: $e');
    }
  }

  /// 删除闹钟
  Future<void> deleteAlarm(String alarmId) async {
    try {
      await _apiService.deleteAlarm(alarmId);
      _alarms.removeWhere((a) => a['id'] == alarmId);
      notifyListeners();
    } catch (e) {
      debugPrint('[AlarmProvider] 删除闹钟失败: $e');
    }
  }
}
