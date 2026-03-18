import 'dart:async';
import 'package:flutter/foundation.dart';

/// 倒计时提醒服务
class TimerService {
  final List<TimerItem> _timers = [];
  
  List<TimerItem> get timers => _timers;
  
  /// 添加倒计时
  String addTimer(int minutes, String label) {
    final id = DateTime.now().millisecondsSinceEpoch.toString();
    final timer = TimerItem(
      id: id,
      label: label,
      endTime: DateTime.now().add(Duration(minutes: minutes)),
    );
    _timers.add(timer);
    timer.start();
    debugPrint('[Timer] 添加倒计时：$label ($minutes分钟)');
    return id;
  }
  
  /// 取消倒计时
  void cancelTimer(String id) {
    final timer = _timers.firstWhere((t) => t.id == id);
    timer.cancel();
    _timers.removeWhere((t) => t.id == id);
  }
}

class TimerItem extends ChangeNotifier {
  final String id;
  final String label;
  final DateTime endTime;
  Timer? _timer;
  bool _completed = false;
  
  TimerItem({
    required this.id,
    required this.label,
    required this.endTime,
  });
  
  bool get completed => _completed;
  
  int get remainingSeconds {
    final diff = endTime.difference(DateTime.now());
    return diff.inSeconds > 0 ? diff.inSeconds : 0;
  }
  
  void start() {
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (remainingSeconds <= 0) {
        _completed = true;
        _timer?.cancel();
        debugPrint('[Timer] 倒计时完成：$label');
      }
      notifyListeners();
    });
  }
  
  void cancel() {
    _timer?.cancel();
  }
}
