import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';

/// 设备发现服务 - 局域网设备搜索
class DeviceDiscoveryService {
  static const int _discoveryPort = 8124;
  static const String _discoveryMessage = 'JINBEIBEI_DISCOVERY';
  
  final _devicesController = StreamController<Map<String, dynamic>>.broadcast();
  Stream<Map<String, dynamic>> get devicesStream => _devicesController.stream;
  
  RawDatagramSocket? _socket;
  bool _isScanning = false;
  
  /// 开始扫描设备
  Future<void> startScan() async {
    if (_isScanning) return;
    
    _isScanning = true;
    
    try {
      // 创建 UDP socket
      _socket = await RawDatagramSocket.bind(InternetAddress.anyIPv4, 0);
      
      // 监听响应
      _socket!.listen((event) {
        if (event == RawSocketEvent.read) {
          final datagram = _socket!.receive();
          if (datagram != null) {
            _handleResponse(datagram);
          }
        }
      });
      
      // 发送广播
      await _sendBroadcast();
      
      // 3 秒后停止扫描
      Future.delayed(const Duration(seconds: 3), () {
        stopScan();
      });
    } catch (e) {
      debugPrint('[DeviceDiscovery] 扫描失败: $e');
      _isScanning = false;
    }
  }
  
  /// 发送广播消息
  Future<void> _sendBroadcast() async {
    final data = _discoveryMessage.codeUnits;
    
    // 广播到 255.255.255.255
    _socket?.send(
      data,
      InternetAddress('255.255.255.255'),
      _discoveryPort,
    );
    
    debugPrint('[DeviceDiscovery] 已发送广播');
  }
  
  /// 处理设备响应
  void _handleResponse(Datagram datagram) {
    try {
      final response = String.fromCharCodes(datagram.data);
      final parts = response.split('|');
      
      if (parts.length >= 3) {
        final device = {
          'id': parts[0],
          'name': parts[1],
          'ip': datagram.address.address,
          'type': parts[2],
        };
        
        _devicesController.add(device);
        debugPrint('[DeviceDiscovery] 发现设备: ${device['name']} (${device['ip']})');
      }
    } catch (e) {
      debugPrint('[DeviceDiscovery] 解析响应失败: $e');
    }
  }
  
  /// 停止扫描
  void stopScan() {
    _socket?.close();
    _socket = null;
    _isScanning = false;
    debugPrint('[DeviceDiscovery] 扫描已停止');
  }
  
  /// 释放资源
  void dispose() {
    stopScan();
    _devicesController.close();
  }
}
