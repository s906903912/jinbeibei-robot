import 'package:flutter/material.dart';
import '../screens/home/home_screen.dart';
import '../screens/chat/chat_screen.dart';
import '../screens/alarm/alarm_screen.dart';
import '../screens/settings/settings_screen.dart';
import '../screens/device/device_pairing_screen.dart';
import '../screens/weather/weather_screen.dart';
import '../screens/todo/todo_screen.dart';
import '../screens/pomodoro/pomodoro_screen.dart';
import '../screens/timer/timer_screen.dart';
import '../screens/news/news_screen.dart';
import '../screens/message_board/message_board_screen.dart';

/// 路由配置
class Routes {
  // 路由名称
  static const String home = '/';
  static const String chat = '/chat';
  static const String alarm = '/alarm';
  static const String settings = '/settings';
  static const String devicePairing = '/device-pairing';
  static const String weather = '/weather';
  static const String todo = '/todo';
  static const String pomodoro = '/pomodoro';
  static const String timer = '/timer';
  static const String news = '/news';
  static const String messageBoard = '/message-board';

  /// 生成路由
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case '/':
        return MaterialPageRoute(builder: (_) => const HomeScreen());
      
      case '/chat':
        final args = settings.arguments as Map<String, dynamic>?;
        return MaterialPageRoute(
          builder: (_) => ChatScreen(
            deviceId: args?['deviceId'] as String?,
          ),
        );
      
      case '/alarm':
        final args = settings.arguments as Map<String, dynamic>?;
        return MaterialPageRoute(
          builder: (_) => AlarmScreen(
            deviceId: args?['deviceId'] as String?,
          ),
        );
      
      case Routes.settings:
        return MaterialPageRoute(builder: (_) => const SettingsScreen());
      
      case Routes.devicePairing:
        return MaterialPageRoute(builder: (_) => const DevicePairingScreen());
      
      case Routes.weather:
        return MaterialPageRoute(builder: (_) => const WeatherScreen());
      
      case Routes.todo:
        return MaterialPageRoute(builder: (_) => const TodoScreen());
      
      case Routes.pomodoro:
        return MaterialPageRoute(builder: (_) => const PomodoroScreen());
      
      case Routes.timer:
        return MaterialPageRoute(builder: (_) => const TimerScreen());
      
      case Routes.news:
        return MaterialPageRoute(builder: (_) => const NewsScreen());
      
      case Routes.messageBoard:
        return MaterialPageRoute(builder: (_) => const MessageBoardScreen());
      
      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(
              child: Text('未找到页面: ${settings.name}'),
            ),
          ),
        );
    }
  }
}
