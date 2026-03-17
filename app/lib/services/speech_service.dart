import 'package:flutter/foundation.dart';
import 'package:speech_to_text/speech_to_text.dart';

/// 语音输入服务
class SpeechService {
  final SpeechToText _speech = SpeechToText();
  bool _isInitialized = false;
  bool _isListening = false;
  
  bool get isListening => _isListening;

  /// 初始化语音识别
  Future<bool> initialize() async {
    if (_isInitialized) return true;
    
    try {
      _isInitialized = await _speech.initialize(
        onError: (error) => debugPrint('[Speech] 错误: $error'),
        onStatus: (status) => debugPrint('[Speech] 状态: $status'),
      );
      return _isInitialized;
    } catch (e) {
      debugPrint('[Speech] 初始化失败: $e');
      return false;
    }
  }

  /// 开始监听
  Future<void> startListening({
    required Function(String) onResult,
    String localeId = 'zh_CN',
  }) async {
    if (!_isInitialized) {
      final success = await initialize();
      if (!success) return;
    }
    
    if (_isListening) return;
    
    _isListening = true;
    
    await _speech.listen(
      onResult: (result) {
        if (result.finalResult) {
          onResult(result.recognizedWords);
        }
      },
      localeId: localeId,
      listenMode: ListenMode.confirmation,
    );
  }

  /// 停止监听
  Future<void> stopListening() async {
    if (!_isListening) return;
    
    await _speech.stop();
    _isListening = false;
  }

  /// 取消监听
  Future<void> cancel() async {
    await _speech.cancel();
    _isListening = false;
  }

  /// 释放资源
  void dispose() {
    _speech.stop();
  }
}
