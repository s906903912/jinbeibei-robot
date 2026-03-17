import 'package:flutter/foundation.dart';
import '../services/api_service.dart';
import '../services/storage_service.dart';

/// 设备状态管理
class DeviceProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();
  
  List<Map<String, dynamic>> _devices = [];
  String? _currentDeviceId;
  
  List<Map<String, dynamic>> get devices => _devices;
  
  Map<String, dynamic>? get currentDevice {
    if (_currentDeviceId == null) return null;
    try {
      return _devices.firstWhere((d) => d['id'] == _currentDeviceId);
    } catch (_) {
      return null;
    }
  }

  /// 加载设备列表
  Future<void> loadDevices() async {
    try {
      _devices = await _apiService.getDevices();
      
      // 加载当前选中的设备
      _currentDeviceId = StorageService.getCurrentDevice();
      
      // 如果没有选中设备，自动选择第一个
      if (_currentDeviceId == null && _devices.isNotEmpty) {
        _currentDeviceId = _devices.first['id'];
        await StorageService.setCurrentDevice(_currentDeviceId!);
      }
      
      notifyListeners();
    } catch (e) {
      debugPrint('[DeviceProvider] 加载设备失败: $e');
    }
  }

  /// 设置音量
  Future<void> setVolume(String deviceId, int volume) async {
    try {
      await _apiService.setVolume(deviceId, volume);
      
      // 更新本地状态
      final index = _devices.indexWhere((d) => d['id'] == deviceId);
      if (index != -1) {
        _devices[index]['volume'] = volume;
        notifyListeners();
      }
    } catch (e) {
      debugPrint('[DeviceProvider] 设置音量失败: $e');
    }
  }

  /// 设置表情
  Future<void> setEmotion(String deviceId, String emotion) async {
    try {
      await _apiService.setEmotion(deviceId, emotion);
      
      // 更新本地状态
      final index = _devices.indexWhere((d) => d['id'] == deviceId);
      if (index != -1) {
        _devices[index]['emotion'] = emotion;
        notifyListeners();
      }
    } catch (e) {
      debugPrint('[DeviceProvider] 设置表情失败: $e');
    }
  }
}
