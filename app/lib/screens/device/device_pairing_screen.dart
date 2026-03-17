import 'package:flutter/material.dart';

/// 设备配对页面
class DevicePairingScreen extends StatefulWidget {
  const DevicePairingScreen({super.key});

  @override
  State<DevicePairingScreen> createState() => _DevicePairingScreenState();
}

class _DevicePairingScreenState extends State<DevicePairingScreen> {
  bool _isScanning = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('添加设备'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (_isScanning)
              const CircularProgressIndicator()
            else
              const Icon(Icons.devices, size: 80, color: Colors.grey),
            const SizedBox(height: 24),
            Text(
              _isScanning ? '正在搜索设备...' : '点击按钮开始搜索',
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: _isScanning ? null : _startScanning,
              icon: const Icon(Icons.search),
              label: const Text('搜索设备'),
            ),
          ],
        ),
      ),
    );
  }

  void _startScanning() {
    setState(() => _isScanning = true);
    
    // TODO: 实现设备搜索
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() => _isScanning = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('未找到设备')),
        );
      }
    });
  }
}
