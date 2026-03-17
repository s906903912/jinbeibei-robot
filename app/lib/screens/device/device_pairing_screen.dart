import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/device_discovery_service.dart';
import '../../providers/device_provider.dart';

/// 设备配对页面
class DevicePairingScreen extends StatefulWidget {
  const DevicePairingScreen({super.key});

  @override
  State<DevicePairingScreen> createState() => _DevicePairingScreenState();
}

class _DevicePairingScreenState extends State<DevicePairingScreen> {
  final DeviceDiscoveryService _discoveryService = DeviceDiscoveryService();
  bool _isScanning = false;
  final List<Map<String, dynamic>> _foundDevices = [];

  @override
  void initState() {
    super.initState();
    _discoveryService.devicesStream.listen((device) {
      setState(() {
        // 避免重复添加
        if (!_foundDevices.any((d) => d['id'] == device['id'])) {
          _foundDevices.add(device);
        }
      });
    });
  }

  @override
  void dispose() {
    _discoveryService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('添加设备'),
      ),
      body: Column(
        children: [
          if (_isScanning)
            const LinearProgressIndicator(),
          Expanded(
            child: _foundDevices.isEmpty
                ? _buildEmptyState()
                : _buildDeviceList(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _isScanning ? null : _startScanning,
        icon: Icon(_isScanning ? Icons.stop : Icons.search),
        label: Text(_isScanning ? '搜索中...' : '搜索设备'),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            _isScanning ? Icons.search : Icons.devices,
            size: 80,
            color: Colors.grey,
          ),
          const SizedBox(height: 24),
          Text(
            _isScanning ? '正在搜索设备...' : '点击按钮开始搜索',
            style: const TextStyle(fontSize: 18),
          ),
          if (!_isScanning) ...[
            const SizedBox(height: 8),
            const Text(
              '确保设备和手机在同一 WiFi',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDeviceList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _foundDevices.length,
      itemBuilder: (context, index) {
        final device = _foundDevices[index];
        return Card(
          child: ListTile(
            leading: const Icon(Icons.devices, size: 40),
            title: Text(device['name'] ?? '未知设备'),
            subtitle: Text('IP: ${device['ip']}\nID: ${device['id']}'),
            trailing: ElevatedButton(
              onPressed: () => _connectDevice(device),
              child: const Text('连接'),
            ),
          ),
        );
      },
    );
  }

  void _startScanning() {
    setState(() {
      _isScanning = true;
      _foundDevices.clear();
    });
    
    _discoveryService.startScan();
    
    // 3 秒后停止
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() => _isScanning = false);
        if (_foundDevices.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('未找到设备')),
          );
        }
      }
    });
  }

  void _connectDevice(Map<String, dynamic> device) {
    // TODO: 保存设备信息
    context.read<DeviceProvider>().loadDevices();
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('已连接到 ${device['name']}')),
    );
    
    Navigator.pop(context);
  }
}
