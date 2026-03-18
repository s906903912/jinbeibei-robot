import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/pomodoro_service.dart';

class PomodoroScreen extends StatelessWidget {
  const PomodoroScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => PomodoroService(),
      child: Scaffold(
        appBar: AppBar(title: const Text('番茄钟')),
        body: Consumer<PomodoroService>(
          builder: (context, pomodoro, _) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    pomodoro.timeDisplay,
                    style: const TextStyle(fontSize: 72, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    pomodoro.isBreak ? '休息中' : '专注中',
                    style: const TextStyle(fontSize: 24),
                  ),
                  const SizedBox(height: 48),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (!pomodoro.isRunning)
                        ElevatedButton(
                          onPressed: () => pomodoro.start(),
                          child: const Text('开始专注'),
                        ),
                      if (pomodoro.isRunning)
                        ElevatedButton(
                          onPressed: () => pomodoro.pause(),
                          child: const Text('暂停'),
                        ),
                      const SizedBox(width: 16),
                      if (!pomodoro.isRunning && pomodoro.remainingSeconds < 25 * 60)
                        ElevatedButton(
                          onPressed: () => pomodoro.resume(),
                          child: const Text('继续'),
                        ),
                      const SizedBox(width: 16),
                      ElevatedButton(
                        onPressed: () => pomodoro.reset(),
                        child: const Text('重置'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => pomodoro.startBreak(),
                    child: const Text('开始休息(5分钟)'),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
