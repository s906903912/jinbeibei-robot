import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../providers/language_provider.dart';

/// 设置页面
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  Future<void> _showWifiConfigDialog(BuildContext context, AppTranslations t) async {
    String? currentWifiName;
    
    // 尝试获取当前 WiFi 名称（仅在某些平台上可用）
    // 注意：WiFi 信息获取在桌面平台不支持，需要 Android/iOS 设备
    if (!kIsWeb && (Platform.isAndroid || Platform.isIOS)) {
      try {
        // TODO: 使用 wifi_info_flutter 或 network_info_plus 获取 WiFi 信息
        // 由于权限和平台限制，这里暂时不实现
      } catch (e) {
        debugPrint('获取 WiFi 信息失败：$e');
      }
    }
    
    final ssidController = TextEditingController(text: currentWifiName ?? 'Home-WiFi');
    final passwordController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Row(
            children: [
              Icon(Icons.wifi, color: Theme.of(context).colorScheme.primary),
              const SizedBox(width: 8),
              Text(t.wifiConfig),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (currentWifiName != null)
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.wifi, size: 16, color: Theme.of(context).colorScheme.onPrimaryContainer),
                      const SizedBox(width: 8),
                      Text(
                        '当前网络：$currentWifiName',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onPrimaryContainer,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: 16),
              TextField(
                controller: ssidController,
                decoration: InputDecoration(
                  labelText: 'SSID',
                  prefixIcon: const Icon(Icons.router),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: '密码',
                  prefixIcon: const Icon(Icons.lock),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(t.cancel),
            ),
            ElevatedButton.icon(
              onPressed: () async {
                Navigator.pop(context);
                // TODO: 保存 WiFi 配置到设备
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(t.wifiConfigSaved(ssidController.text)),
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                );
              },
              icon: const Icon(Icons.save),
              label: Text(t.save),
            ),
          ],
        ),
      ),
    );
  }

  void _showVolumeSliderDialog(BuildContext context, AppTranslations t) {
    int volume = 50;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.volume_up, color: Theme.of(context).colorScheme.primary),
            const SizedBox(width: 8),
            Text(t.volumeSettings),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                '$volume%',
                style: TextStyle(fontSize: 48, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.primary),
              ),
            ),
            const SizedBox(height: 24),
            Slider(
              value: volume.toDouble(),
              min: 0,
              max: 100,
              divisions: 20,
              activeColor: Theme.of(context).colorScheme.primary,
              onChanged: (value) {
                volume = value.round();
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(t.cancel),
          ),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(t.volumeSaved(volume)),
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
              );
            },
            icon: const Icon(Icons.save),
            label: Text(t.save),
          ),
        ],
      ),
    );
  }

  void _showLanguageDialog(BuildContext context, LanguageProvider languageProvider, AppTranslations t) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.language, color: Theme.of(context).colorScheme.primary),
            const SizedBox(width: 8),
            Text(t.language),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: AppLanguage.values.map((lang) {
            return RadioListTile<AppLanguage>(
              contentPadding: const EdgeInsets.symmetric(horizontal: 8),
              title: Text(lang.name),
              value: lang,
              groupValue: languageProvider.language,
              activeColor: Theme.of(context).colorScheme.primary,
              onChanged: (value) async {
                if (value != null) {
                  await languageProvider.setLanguage(value);
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(t.languageChanged(lang.name)),
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                  );
                }
              },
            );
          }).toList(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(t.cancel),
          ),
        ],
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    return Consumer<LanguageProvider>(
      builder: (context, languageProvider, child) {
        final t = languageProvider.t;
        final colorScheme = Theme.of(context).colorScheme;
        
        return Scaffold(
          appBar: AppBar(
            title: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.settings, size: 24),
                const SizedBox(width: 8),
                Text(t.settings),
              ],
            ),
          ),
          body: SafeArea(
            child: ListView(
              children: [
                // 设备设置卡片
                _buildCard(
                  context,
                  Icons.devices,
                  t.deviceSettings,
                  [
                    ListTile(
                      leading: CircleAvatar(
                        backgroundColor: colorScheme.primaryContainer,
                        child: Icon(Icons.wifi, color: colorScheme.onPrimaryContainer),
                      ),
                      title: Text(t.wifiConfig),
                      subtitle: Text(t.networkHint),
                      trailing: Icon(Icons.chevron_right, color: colorScheme.outline),
                      onTap: () => _showWifiConfigDialog(context, t),
                    ),
                    ListTile(
                      leading: CircleAvatar(
                        backgroundColor: colorScheme.primaryContainer,
                        child: Icon(Icons.volume_up, color: colorScheme.onPrimaryContainer),
                      ),
                      title: Text(t.volumeSettings),
                      subtitle: Text(t.volumeHint),
                      trailing: Icon(Icons.chevron_right, color: colorScheme.outline),
                      onTap: () => _showVolumeSliderDialog(context, t),
                    ),
                  ],
                ),
                
                // 应用设置卡片
                _buildCard(
                  context,
                  Icons.tune,
                  t.appSettings,
                  [
                    SwitchListTile(
                      secondary: CircleAvatar(
                        backgroundColor: colorScheme.primaryContainer,
                        child: Icon(Icons.dark_mode, color: colorScheme.onPrimaryContainer),
                      ),
                      title: Text(t.darkMode),
                      subtitle: Text(t.toggleDarkMode),
                      value: languageProvider.isDarkMode,
                      activeColor: colorScheme.primary,
                      onChanged: (_) async {
                        await languageProvider.toggleDarkMode();
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(t.themeToggled(!languageProvider.isDarkMode)),
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                        );
                      },
                    ),
                    ListTile(
                      leading: CircleAvatar(
                        backgroundColor: colorScheme.primaryContainer,
                        child: Icon(Icons.language, color: colorScheme.onPrimaryContainer),
                      ),
                      title: Text(t.language),
                      subtitle: Text(languageProvider.language.name),
                      trailing: Icon(Icons.chevron_right, color: colorScheme.outline),
                      onTap: () => _showLanguageDialog(context, languageProvider, t),
                    ),
                  ],
                ),
                
                // 关于卡片
                _buildCard(
                  context,
                  Icons.info_outline,
                  t.about,
                  [
                    ListTile(
                      leading: CircleAvatar(
                        backgroundColor: colorScheme.secondaryContainer,
                        child: Icon(Icons.info, color: colorScheme.onSecondaryContainer),
                      ),
                      title: Text(t.version),
                      subtitle: Text(t.appName),
                      trailing: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          color: colorScheme.primary,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Text('0.1.0', style: TextStyle(fontSize: 12, color: Colors.white)),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
  
  Widget _buildCard(BuildContext context, IconData icon, String title, List<Widget> children) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: colorScheme.onPrimaryContainer, size: 20),
                ),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface,
                  ),
                ),
              ],
            ),
          ),
          Divider(height: 1, color: colorScheme.outlineVariant.withOpacity(0.3)),
          ...children,
        ],
      ),
    );
  }
}
