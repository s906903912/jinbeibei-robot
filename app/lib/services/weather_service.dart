import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';

/// 天气服务 - 获取天气信息
class WeatherService {
  // 使用免费的天气 API (wttr.in)
  static const String _baseUrl = 'https://wttr.in';
  
  /// 获取天气信息
  Future<Map<String, dynamic>> getWeather({String city = 'Beijing'}) async {
    try {
      final url = Uri.parse('$_baseUrl/$city?format=j1');
      final response = await http.get(url);
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final current = data['current_condition'][0];
        final weather = data['weather'][0];
        
        return {
          'temperature': current['temp_C'],
          'condition': current['weatherDesc'][0]['value'],
          'humidity': current['humidity'],
          'windSpeed': current['windspeedKmph'],
          'maxTemp': weather['maxtempC'],
          'minTemp': weather['mintempC'],
          'city': city,
        };
      } else {
        throw Exception('获取天气失败');
      }
    } catch (e) {
      debugPrint('[Weather] 获取天气失败：$e');
      rethrow;
    }
  }
  
  /// 生成天气播报文本
  String generateWeatherReport(Map<String, dynamic> weather) {
    return '今天${weather['city']}的天气是${weather['condition']}，'
        '温度${weather['minTemp']}到${weather['maxTemp']}度，'
        '当前温度${weather['temperature']}度，湿度${weather['humidity']}%。';
  }
}
