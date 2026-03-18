import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';

/// 新闻服务
class NewsService {
  // 使用免费新闻 API
  static const String _apiUrl = 'https://api.thenewsapi.com/v1/news/top';
  
  /// 获取新闻列表
  Future<List<Map<String, dynamic>>> getNews({String category = 'general'}) async {
    try {
      // 这里使用模拟数据，实际使用时需要 API Key
      return _getMockNews();
    } catch (e) {
      debugPrint('[News] 获取新闻失败：$e');
      return _getMockNews();
    }
  }
  
  /// 模拟新闻数据
  List<Map<String, dynamic>> _getMockNews() {
    return [
      {
        'title': 'AI技术取得新突破',
        'description': '最新研究显示，人工智能在自然语言处理领域取得重大进展...',
        'source': '科技日报',
        'publishedAt': DateTime.now().subtract(const Duration(hours: 2)).toIso8601String(),
      },
      {
        'title': '新能源汽车销量创新高',
        'description': '本月新能源汽车销量同比增长45%，市场持续火热...',
        'source': '财经新闻',
        'publishedAt': DateTime.now().subtract(const Duration(hours: 5)).toIso8601String(),
      },
      {
        'title': '天气预报：明日气温回升',
        'description': '气象台预报，明日气温将回升至20度，适宜出行...',
        'source': '天气网',
        'publishedAt': DateTime.now().subtract(const Duration(hours: 8)).toIso8601String(),
      },
    ];
  }
  
  /// 生成新闻播报文本
  String generateNewsReport(List<Map<String, dynamic>> news) {
    if (news.isEmpty) return '暂无新闻';
    
    final buffer = StringBuffer('以下是今日新闻：');
    for (var i = 0; i < news.length && i < 3; i++) {
      buffer.write('${i + 1}. ${news[i]['title']}。');
    }
    return buffer.toString();
  }
}
