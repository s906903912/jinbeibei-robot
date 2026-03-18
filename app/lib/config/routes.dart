import 'package:flutter/material.dart';
import '../screens/home/home_screen.dart';
import '../screens/chat/chat_screen.dart';
import '../screens/alarm/alarm_screen.dart';
import '../screens/settings/settings_screen.dart';
import '../screens/device/device_pairing_screen.dart';

/// 路由配置
class Routes {
  // 路由名称
  static const String home = '/';
  static const String chat = '/chat';
  static const String alarm = '/alarm';
  static const String settings = '/settings';
  static const String devicePairing = '/device-pairing';

  /// 生成路由
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case home:
        return MaterialPageRoute(builder: (_) => const HomeScreen());
      
      case chat:
        final args = settings.arguments as Map<String, dynamic>?;
        return MaterialPageRoute(
          builder: (_) => ChatScreen(
            deviceId: args?['deviceId'] as String?,
          ),
        );
      
      case alarm:
        final args = settings.arguments as Map<String, dynamic>?;
        return MaterialPageRoute(
          builder: (_) => AlarmScreen(
            deviceId: args?['deviceId'] as String?,
          ),
        );
      
      case Routes.settings:
        return MaterialPageRoute(builder: (_) => const SettingsScreen());
      
      case devicePairing:
        return MaterialPageRoute(builder: (_) => const DevicePairingScreen());
      
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
