import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/device_provider.dart';
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('金贝贝桌面精灵'),
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
            return _buildEmptyState(context);
          }
          
          final device = deviceProvider.currentDevice;
          if (device == null) {
            return _buildEmptyState(context);
          }
          
          return _buildDeviceControl(context, device);
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.pushNamed(context, Routes.devicePairing),
        child: const Icon(Icons.add),
      ),
    );
  }

  /// 空状态 - 无设备
  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.devices, size: 80, color: Colors.grey),
          const SizedBox(height: 16),
          const Text('还没有设备', style: TextStyle(fontSize: 18)),
          const SizedBox(height: 8),
          const Text('点击右下角 + 添加设备', style: TextStyle(color: Colors.grey)),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => Navigator.pushNamed(context, Routes.devicePairing),
            icon: const Icon(Icons.add),
            label: const Text('添加设备'),
          ),
        ],
      ),
    );
  }

  /// 设备控制界面
  Widget _buildDeviceControl(BuildContext context, Map<String, dynamic> device) {
    final isOnline = device['status'] == 'online';
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // 金贝贝形象
          _buildAvatar(context, device),
          const SizedBox(height: 24),
          
          // 设备状态
          _buildStatusCard(device, isOnline),
          const SizedBox(height: 16),
          
          // 快捷功能
          _buildQuickActions(context, device),
          const SizedBox(height: 16),
          
          // 音量控制
          _buildVolumeControl(device),
        ],
      ),
    );
  }

  /// 金贝贝形象
  Widget _buildAvatar(BuildContext context, Map<String, dynamic> device) {
    final emotion = device['emotion'] ?? 'happy';
    
    return Container(
      width: 200,
      height: 200,
      decoration: BoxDecoration(
        color: Colors.amber.shade100,
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              _getEmotionEmoji(emotion),
              style: const TextStyle(fontSize: 80),
            ),
            const SizedBox(height: 8),
            Text(
              device['name'] ?? '金贝贝',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  /// 设备状态卡片
  Widget _buildStatusCard(Map<String, dynamic> device, bool isOnline) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('设备状态'),
                Row(
                  children: [
                    Icon(
                      Icons.circle,
                      size: 12,
                      color: isOnline ? Colors.green : Colors.grey,
                    ),
                    const SizedBox(width: 4),
                    Text(isOnline ? '在线' : '离线'),
                  ],
                ),
              ],
            ),
            const Divider(),
            _buildStatusRow('音量', '${device['volume'] ?? 70}%'),
            _buildStatusRow('亮度', '${device['brightness'] ?? 80}%'),
            if (device['wifi_strength'] != null)
              _buildStatusRow('WiFi', '${device['wifi_strength']} dBm'),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey)),
          Text(value),
        ],
      ),
    );
  }

  /// 快捷功能
  Widget _buildQuickActions(BuildContext context, Map<String, dynamic> device) {
    return Row(
      children: [
        Expanded(
          child: _buildActionButton(
            context,
            icon: Icons.chat,
            label: '对话',
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
            icon: Icons.alarm,
            label: '闹钟',
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
    required VoidCallback onTap,
  }) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              Icon(icon, size: 32),
              const SizedBox(height: 8),
              Text(label),
            ],
          ),
        ),
      ),
    );
  }

  /// 音量控制
  Widget _buildVolumeControl(Map<String, dynamic> device) {
    final volume = (device['volume'] ?? 70).toDouble();
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('音量控制', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.volume_down),
                Expanded(
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
                const Icon(Icons.volume_up),
              ],
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
