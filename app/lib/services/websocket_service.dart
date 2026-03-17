import 'dart:async';
import 'dart:convert';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:flutter/foundation.dart';

/// WebSocket 服务 - 管理与服务器的连接
class WebSocketService extends ChangeNotifier {
  WebSocketChannel? _channel;
  StreamSubscription? _subscription;
  
  bool _isConnected = false;
  bool _isConnecting = false;
  String? _serverUrl;
  
  // 消息流
  final _messageController = StreamController<Map<String, dynamic>>.broadcast();
  Stream<Map<String, dynamic>> get messageStream => _messageController.stream;
  
  // 连接状态
  bool get isConnected => _isConnected;
  bool get isConnecting => _isConnecting;
  String? get serverUrl => _serverUrl;
  
  /// 连接到服务器
  Future<bool> connect(String url, {String? deviceId}) async {
    if (_isConnected || _isConnecting) {
      debugPrint('[WebSocket] 已连接或正在连接中');
      return _isConnected;
    }
    
    try {
      _isConnecting = true;
      _serverUrl = url;
      notifyListeners();
      
      // 构建连接 URL
      final connectUrl = Uri.parse('$url?type=app&id=${deviceId ?? 'app_${DateTime.now().millisecondsSinceEpoch}'}');
      
      debugPrint('[WebSocket] 正在连接到：$connectUrl');
      
      _channel = WebSocketChannel.connect(connectUrl);
      
      // 监听消息
      _subscription = _channel!.stream.listen(
        (data) {
          _handleMessage(data);
        },
        onError: (error) {
          debugPrint('[WebSocket] 错误：$error');
          _isConnected = false;
          _isConnecting = false;
          notifyListeners();
        },
        onDone: () {
          debugPrint('[WebSocket] 连接已关闭');
          _isConnected = false;
          _isConnecting = false;
          notifyListeners();
        },
      );
      
      // 等待连接成功（通过欢迎消息确认）
      await _waitForWelcomeMessage();
      
      _isConnected = true;
      _isConnecting = false;
      notifyListeners();
      
      debugPrint('[WebSocket] 连接成功！');
      return true;
      
    } catch (e) {
      debugPrint('[WebSocket] 连接失败：$e');
      _isConnected = false;
      _isConnecting = false;
      notifyListeners();
      return false;
    }
  }
  
  /// 等待欢迎消息
  Future<bool> _waitForWelcomeMessage() async {
    final completer = Completer<bool>();
    final timeout = Timer(const Duration(seconds: 5), () {
      if (!completer.isCompleted) {
        completer.completeError(TimeoutException('等待欢迎消息超时'));
      }
    });
    
    final subscription = _channel!.stream.listen(
      (data) {
        try {
          final message = jsonDecode(data as String);
          if (message['type'] == 'welcome') {
            if (!completer.isCompleted) {
              completer.complete(true);
            }
          }
        } catch (_) {}
      },
      onError: (error) {
        if (!completer.isCompleted) {
          completer.completeError(error);
        }
      },
    );
    
    try {
      await completer.future;
      subscription.cancel();
      timeout.cancel();
      return true;
    } catch (e) {
      subscription.cancel();
      timeout.cancel();
      rethrow;
    }
  }
  
  /// 处理接收到的消息
  void _handleMessage(dynamic data) {
    try {
      final message = jsonDecode(data as String) as Map<String, dynamic>;
      debugPrint('[WebSocket] 收到消息：$message');
      _messageController.add(message);
    } catch (e) {
      debugPrint('[WebSocket] 消息解析失败：$e');
    }
  }
  
  /// 发送消息
  void send(Map<String, dynamic> message) {
    if (!_isConnected || _channel == null) {
      debugPrint('[WebSocket] 未连接，无法发送消息');
      return;
    }
    
    try {
      _channel!.sink.add(jsonEncode(message));
      debugPrint('[WebSocket] 发送消息：$message');
    } catch (e) {
      debugPrint('[WebSocket] 发送失败：$e');
    }
  }
  
  /// 发送控制命令
  void sendCommand(String action, Map<String, dynamic> data, {String? deviceId}) {
    send({
      'type': 'control_command',
      'action': action,
      'data': data,
      'deviceId': deviceId,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    });
  }
  
  /// 发送聊天消息
  void sendChatMessage(String message, {String? deviceId}) {
    send({
      'type': 'chat_message',
      'message': message,
      'deviceId': deviceId,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    });
  }
  
  /// 发送心跳
  void sendHeartbeat() {
    send({
      'type': 'heartbeat',
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    });
  }
  
  /// 断开连接
  Future<void> disconnect() async {
    if (_subscription != null) {
      await _subscription!.cancel();
      _subscription = null;
    }
    
    if (_channel != null) {
      await _channel!.sink.close();
      _channel = null;
    }
    
    _isConnected = false;
    _isConnecting = false;
    _serverUrl = null;
    notifyListeners();
    
    debugPrint('[WebSocket] 已断开连接');
  }
  
  /// 重连
  Future<bool> reconnect() async {
    if (_serverUrl != null) {
      await disconnect();
      return await connect(_serverUrl!);
    }
    return false;
  }
  
  @override
  void dispose() {
    _messageController.close();
    disconnect();
    super.dispose();
  }
}
