import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/alarm_provider.dart';

/// 闹钟管理页面
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('闹钟管理'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showAddAlarmDialog(),
          ),
        ],
      ),
      body: Consumer<AlarmProvider>(
        builder: (context, alarmProvider, child) {
          final alarms = alarmProvider.alarms;
          
          if (alarms.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.alarm_off, size: 80, color: Colors.grey),
                  SizedBox(height: 16),
                  Text('还没有闹钟', style: TextStyle(fontSize: 18)),
                  SizedBox(height: 8),
                  Text('点击右上角 + 添加闹钟', style: TextStyle(color: Colors.grey)),
                ],
              ),
            );
          }
          
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: alarms.length,
            itemBuilder: (context, index) {
              final alarm = alarms[index];
              return _buildAlarmCard(alarm);
            },
          );
        },
      ),
    );
  }

  Widget _buildAlarmCard(Map<String, dynamic> alarm) {
    final enabled = alarm['enabled'] == true;
    final time = alarm['time'] as String;
    final label = alarm['label'] as String? ?? '';
    final repeat = alarm['repeat'] as List? ?? [];
    
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Icon(
          Icons.alarm,
          color: enabled ? Colors.amber : Colors.grey,
        ),
        title: Text(
          time,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: enabled ? Colors.black : Colors.grey,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (label.isNotEmpty) Text(label),
            Text(_formatRepeat(repeat)),
          ],
        ),
        trailing: Switch(
          value: enabled,
          onChanged: (value) {
            context.read<AlarmProvider>().toggleAlarm(alarm['id']);
          },
        ),
        onTap: () => _showEditAlarmDialog(alarm),
      ),
    );
  }

  String _formatRepeat(List repeat) {
    if (repeat.isEmpty || repeat.contains('everyday')) {
      return '每天';
    }
    
    final weekDays = {
      'mon': '周一',
      'tue': '周二',
      'wed': '周三',
      'thu': '周四',
      'fri': '周五',
      'sat': '周六',
      'sun': '周日',
    };
    
    return repeat.map((d) => weekDays[d] ?? d).join(', ');
  }

  void _showAddAlarmDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('添加闹钟'),
        content: const Text('闹钟添加功能开发中...'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('关闭'),
          ),
        ],
      ),
    );
  }

  void _showEditAlarmDialog(Map<String, dynamic> alarm) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('编辑闹钟'),
        content: Text('编辑闹钟: ${alarm['time']}'),
        actions: [
          TextButton(
            onPressed: () {
              context.read<AlarmProvider>().deleteAlarm(alarm['id']);
              Navigator.pop(context);
            },
            child: const Text('删除', style: TextStyle(color: Colors.red)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('关闭'),
          ),
        ],
      ),
    );
  }
}
