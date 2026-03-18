import 'package:flutter/material.dart';
import '../../services/timer_service.dart';

class TimerScreen extends StatefulWidget {
  const TimerScreen({super.key});

  @override
  State<TimerScreen> createState() => _TimerScreenState();
}

class _TimerScreenState extends State<TimerScreen> {
  final _timerService = TimerService();
  final _labelController = TextEditingController();
  int _minutes = 10;

  void _addTimer() {
    if (_labelController.text.isEmpty) return;
    _timerService.addTimer(_minutes, _labelController.text);
    _labelController.clear();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('倒计时提醒')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                TextField(
                  controller: _labelController,
                  decoration: const InputDecoration(
                    labelText: '提醒内容',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    const Text('时长：'),
                    Expanded(
                      child: Slider(
                        value: _minutes.toDouble(),
                        min: 1,
                        max: 60,
                        divisions: 59,
                        label: '$_minutes 分钟',
                        onChanged: (v) => setState(() => _minutes = v.toInt()),
                      ),
                    ),
                    Text('$_minutes 分钟'),
                  ],
                ),
                ElevatedButton(
                  onPressed: _addTimer,
                  child: const Text('添加倒计时'),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _timerService.timers.length,
              itemBuilder: (context, index) {
                final timer = _timerService.timers[index];
                return ListenableBuilder(
                  listenable: timer,
                  builder: (context, _) {
                    final mins = timer.remainingSeconds ~/ 60;
                    final secs = timer.remainingSeconds % 60;
                    return ListTile(
                      title: Text(timer.label),
                      subtitle: Text(
                        timer.completed
                            ? '已完成'
                            : '$mins:${secs.toString().padLeft(2, '0')}',
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () {
                          _timerService.cancelTimer(timer.id);
                          setState(() {});
                        },
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
