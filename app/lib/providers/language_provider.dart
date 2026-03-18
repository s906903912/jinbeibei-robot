import 'package:flutter/material.dart';
import '../services/storage_service.dart';

/// 语言配置
class AppLanguage {
  final String code;
  final String name;
  
  const AppLanguage(this.code, this.name);
  
  static const AppLanguage chinese = AppLanguage('zh', '中文');
  static const AppLanguage english = AppLanguage('en', 'English');
  
  static List<AppLanguage> get values => [chinese, english];
}

/// 翻译文本
class AppTranslations {
  final String languageCode;
  
  const AppTranslations(this.languageCode);
  
  // 应用名称
  String get appName => languageCode == 'en' ? 'JinBeibei Spirit' : '金贝贝桌面精灵';
  
  // 通用文本
  String get settings => languageCode == 'en' ? 'Settings' : '设置';
  String get deviceSettings => languageCode == 'en' ? 'Device Settings' : '设备设置';
  String get appSettings => languageCode == 'en' ? 'App Settings' : '应用设置';
  String get about => languageCode == 'en' ? 'About' : '关于';
  String get wifiConfig => languageCode == 'en' ? 'WiFi Configuration' : 'WiFi 配置';
  String get volumeSettings => languageCode == 'en' ? 'Volume Settings' : '音量设置';
  String get theme => languageCode == 'en' ? 'Theme' : '主题';
  String get language => languageCode == 'en' ? 'Language' : '语言';
  String get version => languageCode == 'en' ? 'Version' : '版本';
  String get github => languageCode == 'en' ? 'GitHub' : 'GitHub';
  String get darkMode => languageCode == 'en' ? 'Dark Mode' : '深色模式';
  String get toggleDarkMode => languageCode == 'en' ? 'Toggle dark theme' : '切换深色主题';
  
  // 首页文本
  String get addDevice => languageCode == 'en' ? 'Add Device' : '添加设备';
  String get noDevices => languageCode == 'en' ? 'No Devices Yet' : '还没有设备';
  String get noDevicesHint => languageCode == 'en'
      ? 'Tap the button in the bottom right corner to add your first JinBeibei device'
      : '点击右下角按钮添加你的第一个金贝贝设备';
  String get online => languageCode == 'en' ? 'Online' : '在线';
  String get offline => languageCode == 'en' ? 'Offline' : '离线';
  String get volume => languageCode == 'en' ? 'Volume' : '音量';
  String get brightness => languageCode == 'en' ? 'Brightness' : '亮度';
  String get signal => languageCode == 'en' ? 'Signal' : '信号';
  String get chat => languageCode == 'en' ? 'Chat' : '对话';
  String get alarm => languageCode == 'en' ? 'Alarm' : '闹钟';
  String get volumeControl => languageCode == 'en' ? 'Volume Control' : '音量控制';
  String get networkHint => languageCode == 'en' ? 'Configure device network' : '配置设备连接的网络';
  String get volumeHint => languageCode == 'en' ? 'Adjust device volume' : '调节设备音量大小';
  
  // 按钮文本
  String get cancel => languageCode == 'en' ? 'Cancel' : '取消';
  String get save => languageCode == 'en' ? 'Save' : '保存';
  String get ok => languageCode == 'en' ? 'OK' : '确定';
  
  // 提示消息
  String wifiConfigSaved(String wifiName) => languageCode == 'en'
      ? 'WiFi configured: $wifiName'
      : 'WiFi 已配置：$wifiName';
  String volumeSaved(int volume) => languageCode == 'en'
      ? 'Volume set to $volume%'
      : '音量已设置为 $volume%';
  String languageChanged(String lang) => languageCode == 'en'
      ? 'Language changed to $lang'
      : '语言已切换到 $lang';
  String themeToggled(bool isDark) => languageCode == 'en'
      ? (isDark ? 'Dark mode enabled' : 'Light mode enabled')
      : (isDark ? '已启用深色模式' : '已启用浅色模式');
}

/// 语言状态管理
class LanguageProvider extends ChangeNotifier {
  AppLanguage _language = AppLanguage.chinese;
  bool _isDarkMode = false;
  ThemeMode _themeMode = ThemeMode.light;
  
  AppLanguage get language => _language;
  bool get isDarkMode => _isDarkMode;
  ThemeMode get themeMode => _themeMode;
  
  AppTranslations get t => AppTranslations(_language.code);
  
  LanguageProvider() {
    _loadPreferences();
  }
  
  /// 加载用户偏好设置
  Future<void> _loadPreferences() async {
    try {
      // 从存储加载语言
      final savedLanguage = StorageService.getSetting('language') as String?;
      if (savedLanguage != null) {
        _language = AppLanguage.values.firstWhere(
          (l) => l.code == savedLanguage,
          orElse: () => AppLanguage.chinese,
        );
      }
      
      // 从存储加载主题
      final savedTheme = StorageService.getSetting('dark_mode') as bool?;
      if (savedTheme != null) {
        _isDarkMode = savedTheme;
        _themeMode = savedTheme ? ThemeMode.dark : ThemeMode.light;
      }
      
      notifyListeners();
    } catch (e) {
      debugPrint('[LanguageProvider] 加载偏好设置失败：$e');
    }
  }
  
  /// 切换语言
  Future<void> setLanguage(AppLanguage language) async {
    _language = language;
    await StorageService.saveSetting('language', language.code);
    notifyListeners();
  }
  
  /// 切换深色模式
  Future<void> toggleDarkMode() async {
    _isDarkMode = !_isDarkMode;
    _themeMode = _isDarkMode ? ThemeMode.dark : ThemeMode.light;
    await StorageService.saveSetting('dark_mode', _isDarkMode);
    notifyListeners();
  }
  
  /// 设置主题模式
  Future<void> setThemeMode(ThemeMode mode) async {
    _themeMode = mode;
    _isDarkMode = mode == ThemeMode.dark;
    await StorageService.saveSetting('dark_mode', _isDarkMode);
    notifyListeners();
  }
}
