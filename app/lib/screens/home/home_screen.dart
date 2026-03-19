import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/device_provider.dart';
import '../../providers/language_provider.dart';
import '../../config/routes.dart';
import '../../config/theme.dart';

/// 首页 - 设备控制（酷炫精致版）
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _rotateAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);
    
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    
    _rotateAnimation = Tween<double>(begin: 0.0, end: 360.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.linear),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DeviceProvider>().loadDevices();
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<LanguageProvider>(
      builder: (context, languageProvider, child) {
        final t = languageProvider.t;
        return Scaffold(
          body: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Theme.of(context).colorScheme.background,
                  Theme.of(context).colorScheme.surface,
                ],
              ),
            ),
            child: SafeArea(
              child: Column(
                children: [
                  _buildAppBar(context, t),
                  Expanded(
                    child: Consumer<DeviceProvider>(
                      builder: (context, deviceProvider, child) {
                        if (deviceProvider.devices.isEmpty) {
                          return _buildEmptyState(context, t);
                        }
                        
                        final device = deviceProvider.currentDevice;
                        if (device == null) {
                          return _buildEmptyState(context, t);
                        }
                        
                        return _buildDeviceControl(context, device, t);
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
          floatingActionButton: _buildFloatingButton(context, t),
        );
      },
    );
  }

  /// 顶部导航栏
  Widget _buildAppBar(BuildContext context, AppTranslations t) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  gradient: AppTheme.primaryGradient,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.primaryColor.withOpacity(0.4),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Icon(Icons.emoji_emotions, color: Colors.white, size: 24),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    t.appName,
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    '桌面精灵伴侣',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                    ),
                  ),
                ],
              ),
            ],
          ),
          Container(
            decoration: AppTheme.glassEffect(color: Theme.of(context).colorScheme.surface.withOpacity(0.8)),
            child: IconButton(
              icon: const Icon(Icons.settings_rounded),
              onPressed: () => Navigator.pushNamed(context, Routes.settings),
              iconSize: 24,
            ),
          ),
        ],
      ),
    );
  }

  /// 空状态 - 无设备
  Widget _buildEmptyState(AppTranslations t) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return Center(
      child: Container(
        margin: const EdgeInsets.all(24),
        padding: const EdgeInsets.all(40),
        decoration: AppTheme.glassEffect(color: colorScheme.surface.withOpacity(0.9)),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: AppTheme.primaryGradient,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.primaryColor.withOpacity(0.4),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: const Icon(Icons.devices_rounded, size: 64, color: Colors.white),
            ),
            const SizedBox(height: 32),
            Text(
              t.noDevices,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              t.noDevicesHint,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => Navigator.pushNamed(context, Routes.devicePairing),
                icon: const Icon(Icons.add_rounded),
                label: Text(t.addDevice),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 设备控制界面
  Widget _buildDeviceControl(BuildContext context, Map<String, dynamic> device, AppTranslations t) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // 金贝贝形象
          _buildAvatar(context, device),
          const SizedBox(height: 24),
          
          // 设备状态
          _buildStatusCard(context, device, t),
          const SizedBox(height: 16),
          
          // 快捷功能
          _buildQuickActions(context, device, t),
          const SizedBox(height: 16),
          
          // 音量控制
          _buildVolumeControl(context, device, t),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  /// 金贝贝形象 - 带动画效果
  Widget _buildAvatar(BuildContext context, Map<String, dynamic> device) {
    final emotion = device['emotion'] ?? 'happy';
    final colorScheme = Theme.of(context).colorScheme;
    
    return ScaleTransition(
      scale: _pulseAnimation,
      child: Container(
        width: 200,
        height: 200,
        decoration: BoxDecoration(
          gradient: AppTheme.vibrantGradient,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: AppTheme.primaryColor.withOpacity(0.5),
              blurRadius: 30,
              offset: const Offset(0, 12),
              spreadRadius: 2,
            ),
          ],
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            // 外圈旋转装饰
            AnimatedBuilder(
              animation: _rotateAnimation,
              builder: (context, child) {
                return Transform.rotate(
                  angle: _rotateAnimation.value * 3.14159 / 180,
                  child: CustomPaint(
                    size: const Size(200, 200),
                    painter: RingPainter(color: Colors.white.withOpacity(0.3)),
                  ),
                );
              },
            ),
            // 内圈光晕
            Container(
              width: 180,
              height: 180,
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  colors: [
                    Colors.white.withOpacity(0.2),
                    Colors.transparent,
                  ],
                ),
                shape: BoxShape.circle,
              ),
            ),
            // 金贝贝表情和名字
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  _getEmotionEmoji(emotion),
                  style: const TextStyle(fontSize: 72),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.9),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    device['name'] ?? '金贝贝',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onSurface,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// 设备状态卡片 - 毛玻璃效果
  Widget _buildStatusCard(BuildContext context, Map<String, dynamic> device, AppTranslations t) {
    final isOnline = device['status'] == 'online';
    final colorScheme = Theme.of(context).colorScheme;
    
    return Container(
      decoration: AppTheme.glassEffect(color: colorScheme.surface.withOpacity(0.9)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  t.deviceSettings,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: isOnline ? [Colors.green.shade400, Colors.green.shade600] : [Colors.grey.shade400, Colors.grey.shade600],
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: (isOnline ? Colors.green : Colors.grey).withOpacity(0.4),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
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
                      const SizedBox(width: 8),
                      Text(
                        isOnline ? t.online : t.offline,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            _buildStatusItem(context, t.volume, '${device['volume'] ?? 70}%', Icons.volume_up_rounded, Colors.blue),
            const SizedBox(height: 12),
            _buildStatusItem(context, t.brightness, '${device['brightness'] ?? 80}%', Icons.light_mode_rounded, Colors.orange),
            if (device['wifi_strength'] != null) ...[
              const SizedBox(height: 12),
              _buildStatusItem(context, t.signal, '${device['wifi_strength']} dBm', Icons.wifi_rounded, Colors.green),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStatusItem(BuildContext context, String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: color.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: color.withOpacity(0.4),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Icon(icon, size: 20, color: Colors.white),
          ),
          const SizedBox(width: 16),
          Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
            ),
          ),
          const Spacer(),
          Text(
            value,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  /// 快捷功能 - 渐变卡片
  Widget _buildQuickActions(BuildContext context, Map<String, dynamic> device, AppTranslations t) {
    return Row(
      children: [
        Expanded(
          child: _buildActionCard(
            context,
            gradient: const LinearGradient(
              colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
            ),
            icon: Icons.chat_bubble_rounded,
            label: t.chat,
            onTap: () => Navigator.pushNamed(
              context,
              Routes.chat,
              arguments: {'deviceId': device['id']},
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildActionCard(
            context,
            gradient: const LinearGradient(
              colors: [Color(0xFFF093FB), Color(0xFFF5576C)],
            ),
            icon: Icons.alarm_rounded,
            label: t.alarm,
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

  Widget _buildActionCard(
    BuildContext context, {
    required LinearGradient gradient,
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: gradient.colors.first.withOpacity(0.4),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, size: 32, color: Colors.white),
                ),
                const SizedBox(height: 12),
                Text(
                  label,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                    fontSize: 15,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// 音量控制 - 精致滑块
  Widget _buildVolumeControl(BuildContext context, Map<String, dynamic> device, AppTranslations t) {
    final volume = (device['volume'] ?? 70).toDouble();
    final colorScheme = Theme.of(context).colorScheme;
    
    return Container(
      decoration: AppTheme.glassEffect(color: colorScheme.surface.withOpacity(0.9)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.purple.shade400, Colors.purple.shade600],
                    ),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.purple.withOpacity(0.4),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Icon(Icons.volume_up_rounded, size: 20, color: Colors.white),
                ),
                const SizedBox(width: 12),
                Text(
                  t.volumeControl,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Icon(Icons.volume_off_rounded, size: 22, color: colorScheme.primary.withOpacity(0.6)),
                const SizedBox(width: 16),
                Expanded(
                  child: SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                      activeTrackColor: colorScheme.primary,
                      inactiveTrackColor: colorScheme.primary.withOpacity(0.3),
                      thumbColor: colorScheme.primary,
                      overlayColor: colorScheme.primary.withOpacity(0.2),
                      thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 12),
                      overlayShape: const RoundSliderOverlayShape(overlayRadius: 20),
                      trackHeight: 6,
                    ),
                    child: Slider(
                      value: volume,
                      min: 0,
                      max: 100,
                      divisions: 20,
                      label: '${volume.round()}%',
                      onChanged: (value) {
                        context.read<DeviceProvider>().setVolume(
                          device['id'],
                          value.round(),
                        );
                      },
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Icon(Icons.volume_up_rounded, size: 22, color: colorScheme.primary.withOpacity(0.6)),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: colorScheme.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: colorScheme.primary.withOpacity(0.3),
                    ),
                  ),
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
          ],
        ),
      ),
    );
  }

  /// 悬浮按钮
  Widget _buildFloatingButton(BuildContext context, AppTranslations t) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryColor.withOpacity(0.5),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: FloatingActionButton.extended(
        onPressed: () => Navigator.pushNamed(context, Routes.devicePairing),
        icon: const Icon(Icons.add_link_rounded),
        label: Text(t.addDevice),
        elevation: 6,
      ),
    );
  }

  /// 获取表情 Emoji
  String _getEmotionEmoji(String emotion) {
    switch (emotion) {
      case 'happy': return '😊';
      case 'sad': return '😢';
      case 'angry': return '😠';
      case 'sleepy': return '😴';
      case 'excited': return '🤩';
      default: return '🐤';
    }
  }
}

/// 环形装饰绘制器
class RingPainter extends CustomPainter {
  final Color color;
  
  RingPainter({required this.color});
  
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 5;
    
    // 绘制虚线圆环
    for (int i = 0; i < 12; i++) {
      final startAngle = (i * 30) * 3.14159 / 180;
      final endAngle = ((i * 30) + 15) * 3.14159 / 180;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        endAngle - startAngle,
        false,
        paint,
      );
    }
  }
  
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
