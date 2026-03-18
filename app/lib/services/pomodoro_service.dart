import 'dart:async';
import 'package:flutter/foundation.dart';

/// 番茄钟服务
class PomodoroService extends ChangeNotifier {
  Timer? _timer;
  int _remainingSeconds = 25 * 60; // 默认25分钟
  bool _isRunning = false;
  bool _isBreak = false;
  
  int get remainingSeconds => _remainingSeconds;
  bool get isRunning => _isRunning;
  bool get isBreak => _isBreak;
  
  String get timeDisplay {
    final minutes = _remainingSeconds ~/ 60;
    final seconds = _remainingSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }
  
  /// 开始番茄钟
  void start({int minutes = 25}) {
    _remainingSeconds = minutes * 60;
    _isRunning = true;
    _isBreak = false;
    _startTimer();
    notifyListeners();
  }
  
  /// 开始休息
  void startBreak({int minutes = 5}) {
    _remainingSeconds = minutes * 60;
    _isRunning = true;
    _isBreak = true;
    _startTimer();
    notifyListeners();
  }
  
  /// 暂停
  void pause() {
    _isRunning = false;
    _timer?.cancel();
    notifyListeners();
  }
  
  /// 继续
  void resume() {
    _isRunning = true;
    _startTimer();
    notifyListeners();
  }
  
  /// 重置
  void reset() {
    _timer?.cancel();
    _isRunning = false;
    _remainingSeconds = 25 * 60;
    notifyListeners();
  }
  
  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds > 0) {
        _remainingSeconds--;
        notifyListeners();
      } else {
        _onComplete();
      }
    });
  }
  
  void _onComplete() {
    _timer?.cancel();
    _isRunning = false;
    debugPrint('[Pomodoro] ${_isBreak ? "休息" : "专注"}时间结束');
    notifyListeners();
  }
  
  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
