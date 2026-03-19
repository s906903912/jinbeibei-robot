import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/alarm_provider.dart';
import '../../providers/language_provider.dart';
import '../../config/theme.dart';

/// 闹钟管理页面 - 酷炫精致版
class AlarmScreen extends StatefulWidget {
  final String? deviceId;
  
  const AlarmScreen({super.key, this.deviceId});

  @override
  State<AlarmScreen> createState() => _AlarmScreenState();
}

class _AlarmScreenState extends State<AlarmScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AlarmProvider>().loadAlarms(widget.deviceId ?? '');
    });
  }

  @override
  Widget build(BuildContext context) {
    final t = context.read<LanguageProvider>().t;
    
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
              _buildAppBar(context),
              Expanded(
                child: Consumer<AlarmProvider>(
                  builder: (context, alarmProvider, child) {
                    final alarms = alarmProvider.alarms;
                    
                    if (alarms.isEmpty) {
                      return _buildEmptyState(context);
                    }
                    
                    return ListView.builder(
                      padding: const EdgeInsets.all(20),
                      itemCount: alarms.length,
                      itemBuilder: (context, index) {
                        final alarm = alarms[index];
                        return _buildAlarmCard(context, alarm, t);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: _buildFloatingButton(context),
    );
  }

  /// 顶部导航栏
  Widget _buildAppBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        children: [
          Container(
            decoration: AppTheme.glassEffect(
              color: Theme.of(context).colorScheme.surface.withOpacity(0.8),
            ),
            child: IconButton(
              icon: const Icon(Icons.arrow_back_rounded),
              onPressed: () => Navigator.pop(context),
              iconSize: 24,
            ),
          ),
          const SizedBox(width: 16),
          Text(
            '闹钟管理',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  /// 空状态
  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Container(
        margin: const EdgeInsets.all(32),
        padding: const EdgeInsets.all(40),
        decoration: AppTheme.glassEffect(
          color: Theme.of(context).colorScheme.surface.withOpacity(0.8),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFFF9A56), Color(0xFFFFCD75)],
                ),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.orange.withOpacity(0.4),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: const Icon(Icons.alarm_rounded, size: 56, color: Colors.white),
            ),
            const SizedBox(height: 24),
            Text(
              '还没有闹钟',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              '点击右上角 + 添加新闹钟',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 闹钟卡片
  Widget _buildAlarmCard(BuildContext context, Map<String, dynamic> alarm, AppTranslations t) {
    final enabled = alarm['enabled'] == true;
    final time = alarm['time'] as String;
    final label = alarm['label'] as String? ?? '';
    final repeat = alarm['repeat'] as List? ?? [];
    
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: AppTheme.glassEffect(
        color: enabled
            ? Theme.of(context).colorScheme.surface.withOpacity(0.95)
            : Theme.of(context).colorScheme.surface.withOpacity(0.7),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _toggleAlarm(alarm),
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                // 左侧时间显示
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              gradient: enabled
                                  ? const LinearGradient(
                                      colors: [Color(0xFFFF9A56), Color(0xFFFFCD75)],
                                    )
                                  : LinearGradient(
                                      colors: [Colors.grey.shade300, Colors.grey.shade400],
                                    ),
                              borderRadius: BorderRadius.circular(14),
                              boxShadow: enabled
                                  ? [
                                      BoxShadow(
                                        color: Colors.orange.withOpacity(0.3),
                                        blurRadius: 12,
                                        offset: const Offset(0, 4),
                                      ),
                                    ]
                                  : null,
                            ),
                            child: Icon(
                              Icons.alarm_rounded,
                              color: enabled ? Colors.white : Colors.grey.shade600,
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _formatTimeDisplay(time),
                                style: Theme.of(context).textTheme.displaySmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: enabled
                                      ? Theme.of(context).colorScheme.onSurface
                                      : Colors.grey.shade400,
                                ),
                              ),
                              if (label.isNotEmpty) ...[
                                const SizedBox(height: 4),
                                Text(
                                  label,
                                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ],
                      ),
                      if (repeat.isNotEmpty) ...[
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 6,
                          runSpacing: 6,
                          children: repeat.map((day) {
                            return Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: enabled
                                    ? Theme.of(context).colorScheme.primary.withOpacity(0.15)
                                    : Colors.grey.shade200,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                _getDayAbbreviation(day.toString()),
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: enabled
                                      ? Theme.of(context).colorScheme.primary
                                      : Colors.grey.shade600,
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ],
                    ],
                  ),
                ),
                // 右侧开关
                Transform.scale(
                  scale: 1.2,
                  child: Switch(
                    value: enabled,
                    onChanged: (value) => _toggleAlarm(alarm),
                    activeColor: Theme.of(context).colorScheme.primary,
                    activeTrackColor: Theme.of(context).primaryColor.withOpacity(0.5),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// 悬浮按钮
  Widget _buildFloatingButton(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: const LinearGradient(
          colors: [Color(0xFFFF9A56), Color(0xFFFFCD75)],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.orange.withOpacity(0.5),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: FloatingActionButton(
        onPressed: () => _showAddAlarmDialog(),
        backgroundColor: Colors.transparent,
        elevation: 0,
        child: const Icon(Icons.add_rounded, color: Colors.white, size: 28),
      ),
    );
  }

  void _toggleAlarm(Map<String, dynamic> alarm) {
    final alarmId = alarm['id'] as String;
    final newEnabled = !(alarm['enabled'] == true);
    context.read<AlarmProvider>().updateAlarm(
      alarmId,
      enabled: newEnabled,
    );
  }

  void _showAddAlarmDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('添加闹钟'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // TODO: 实现添加闹钟表单
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          ElevatedButton(
            onPressed: () {},
            child: const Text('保存'),
          ),
        ],
      ),
    );
  }

  String _formatTimeDisplay(String time) {
    try {
      final parts = time.split(':');
      final hour = int.parse(parts[0]);
      final minute = int.parse(parts[1]);
      return '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return time;
    }
  }

  String _getDayAbbreviation(String day) {
    const days = {
      '1': '一',
      '2': '二',
      '3': '三',
      '4': '四',
      '5': '五',
      '6': '六',
      '0': '日',
      '7': '日',
    };
    return '周${days[day] ?? day}';
  }
}
