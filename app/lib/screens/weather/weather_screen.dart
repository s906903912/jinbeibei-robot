import 'package:flutter/material.dart';
import '../../services/weather_service.dart';

class WeatherScreen extends StatefulWidget {
  const WeatherScreen({super.key});

  @override
  State<WeatherScreen> createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {
  final _weatherService = WeatherService();
  Map<String, dynamic>? _weather;
  bool _loading = false;
  String _city = 'Beijing';

  @override
  void initState() {
    super.initState();
    _loadWeather();
  }

  Future<void> _loadWeather() async {
    setState(() => _loading = true);
    try {
      final weather = await _weatherService.getWeather(city: _city);
      setState(() => _weather = weather);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('获取天气失败：$e')),
        );
      }
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('天气')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _weather == null
              ? const Center(child: Text('暂无天气数据'))
              : RefreshIndicator(
                  onRefresh: _loadWeather,
                  child: ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            children: [
                              Text(
                                '${_weather!['temperature']}°C',
                                style: Theme.of(context).textTheme.displayLarge,
                              ),
                              Text(_weather!['condition']),
                              const SizedBox(height: 16),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceAround,
                                children: [
                                  _buildInfoItem('最高', '${_weather!['maxTemp']}°C'),
                                  _buildInfoItem('最低', '${_weather!['minTemp']}°C'),
                                  _buildInfoItem('湿度', '${_weather!['humidity']}%'),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
    );
  }

  Widget _buildInfoItem(String label, String value) {
    return Column(
      children: [
        Text(label, style: const TextStyle(color: Colors.grey)),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
      ],
    );
  }
}
