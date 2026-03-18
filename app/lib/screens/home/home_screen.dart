import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/device_provider.dart';
import '../../providers/language_provider.dart';
import '../../config/routes.dart';

/// 首页 - 设备控制
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    // 初始化时尝试连接设备
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DeviceProvider>().loadDevices();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<LanguageProvider>(
      builder: (context, languageProvider, child) {
        final t = languageProvider.t;
        return Scaffold(
          appBar: AppBar(
            title: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.emoji_emotions, color: Theme.of(context).colorScheme.primary),
                const SizedBox(width: 8),
                Text(t.appName),
              ],
            ),
            centerTitle: true,
            actions: [
              IconButton(
                icon: const Icon(Icons.settings),
                onPressed: () => Navigator.pushNamed(context, Routes.settings),
              ),
            ],
          ),
          body: Consumer<DeviceProvider>(
        builder: (context, deviceProvider, child) {
          if (deviceProvider.devices.isEmpty) {
            return _buildEmptyState(context, languageProvider.t);
          }
          
          final device = deviceProvider.currentDevice;
          if (device == null) {
            return _buildEmptyState(context, languageProvider.t);
          }
          
          return _buildDeviceControl(context, device);
        },
      ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () => Navigator.pushNamed(context, Routes.devicePairing),
            icon: const Icon(Icons.add_link),
            label: Text(t.addDevice),
          ),
        );
      },
    );
  }

  /// 空状态 - 无设备
  Widget _buildEmptyState(BuildContext context, AppTranslations t) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return Center(
      child: Container(
        padding: const EdgeInsets.all(32),
        constraints: const BoxConstraints(maxWidth: 400),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: colorScheme.primaryContainer,
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.devices, size: 80, color: colorScheme.onPrimaryContainer),
            ),
            const SizedBox(height: 24),
            Text(
              t.noDevices,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              t.noDevicesHint,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: colorScheme.onSurface.withOpacity(0.7),
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () => Navigator.pushNamed(context, Routes.devicePairing),
              icon: const Icon(Icons.add),
              label: Text(t.addDevice),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 设备控制界面
  Widget _buildDeviceControl(BuildContext context, Map<String, dynamic> device) {
    final isOnline = device['status'] == 'online';
    final colorScheme = Theme.of(context).colorScheme;
    final t = context.read<LanguageProvider>().t;
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // 金贝贝形象
          _buildAvatar(context, device, colorScheme),
          const SizedBox(height: 24),
          
          // 设备状态
          _buildStatusCard(context, device, isOnline, colorScheme, t),
          const SizedBox(height: 16),
          
          // 快捷功能
          _buildQuickActions(context, device, colorScheme, t),
          const SizedBox(height: 16),
          
          // 音量控制
          _buildVolumeControl(context, device, colorScheme, t),
        ],
      ),
    );
  }

  /// 金贝贝形象
  Widget _buildAvatar(BuildContext context, Map<String, dynamic> device, ColorScheme colorScheme) {
    final emotion = device['emotion'] ?? 'happy';
    
    return Container(
      width: 180,
      height: 180,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            colorScheme.primaryContainer,
            colorScheme.secondaryContainer,
          ],
        ),
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: colorScheme.primary.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // 外圈动画效果
          Positioned.fill(
            child: CustomPaint(
              painter: RingPainter(color: colorScheme.primary.withOpacity(0.3)),
            ),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                _getEmotionEmoji(emotion),
                style: const TextStyle(fontSize: 70),
              ),
              const SizedBox(height: 8),
              Text(
                device['name'] ?? '金贝贝',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// 设备状态卡片
  Widget _buildStatusCard(BuildContext context, Map<String, dynamic> device, bool isOnline, ColorScheme colorScheme, AppTranslations t) {
    return Container(
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
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  t.deviceSettings,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: isOnline ? Colors.green : Colors.grey,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        isOnline ? t.online : t.offline,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildStatusRow(context, t.volume, '${device['volume'] ?? 70}%', Icons.volume_up),
            _buildStatusRow(context, t.brightness, '${device['brightness'] ?? 80}%', Icons.light_mode),
            if (device['wifi_strength'] != null)
              _buildStatusRow(context, t.signal, '${device['wifi_strength']} dBm', Icons.wifi),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusRow(BuildContext context, String label, String value, IconData icon) {
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 18, color: colorScheme.onPrimaryContainer),
          ),
          const SizedBox(width: 12),
          Text(
            label,
            style: TextStyle(
              color: colorScheme.onSurface.withOpacity(0.7),
              fontSize: 14,
            ),
          ),
          const Spacer(),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: colorScheme.onSurface,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  /// 快捷功能
  Widget _buildQuickActions(BuildContext context, Map<String, dynamic> device, ColorScheme colorScheme, AppTranslations t) {
    return Row(
      children: [
        Expanded(
          child: _buildActionButton(
            context,
            icon: Icons.chat_bubble_outline,
            label: t.chat,
            color: Colors.purple.shade100,
            iconColor: Colors.purple,
            onTap: () => Navigator.pushNamed(
              context,
              Routes.chat,
              arguments: {'deviceId': device['id']},
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildActionButton(
            context,
            icon: Icons.alarm_outlined,
            label: t.alarm,
            color: Colors.orange.shade100,
            iconColor: Colors.orange,
            onTap: () => Navigator.pushNamed(
              context,
              Routes.alarm,
              arguments: {'deviceId': device['id']},
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required Color color,
    required Color iconColor,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Icon(icon, size: 32, color: iconColor),
                const SizedBox(height: 8),
                Text(
                  label,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: iconColor,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// 音量控制
  Widget _buildVolumeControl(BuildContext context, Map<String, dynamic> device, ColorScheme colorScheme, AppTranslations t) {
    final volume = (device['volume'] ?? 70).toDouble();
    
    return Container(
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
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(Icons.volume_up, size: 20, color: colorScheme.onPrimaryContainer),
                ),
                const SizedBox(width: 12),
                Text(
                  t.volumeControl,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Icon(Icons.volume_off, size: 20, color: colorScheme.onSurface.withOpacity(0.5)),
                const SizedBox(width: 12),
                Expanded(
                  child: Slider(
                    value: volume,
                    min: 0,
                    max: 100,
                    divisions: 20,
                    activeColor: colorScheme.primary,
                    label: '${volume.round()}%',
                    onChanged: (value) {
                      context.read<DeviceProvider>().setVolume(
                        device['id'],
                        value.round(),
                      );
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Icon(Icons.volume_up, size: 20, color: colorScheme.onSurface.withOpacity(0.5)),
              ],
            ),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                '${volume.round()}%',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: colorScheme.primary,
                  fontSize: 16,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 获取表情 Emoji
  String _getEmotionEmoji(String emotion) {
    switch (emotion) {
      case 'happy':
        return '😊';
      case 'sad':
        return '😢';
      case 'angry':
        return '😠';
      case 'sleepy':
        return '😴';
      case 'excited':
        return '🤩';
      default:
        return '🐤';
    }
  }
}

/// 环形动画绘制器
class RingPainter extends CustomPainter {
  final Color color;
  
  RingPainter({required this.color});
  
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;
    
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 10;
    
    canvas.drawCircle(center, radius, paint);
  }
  
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
