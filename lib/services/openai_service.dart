import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/sleep_entry.dart';

// OpenAI APIを呼び出す処理
class OpenAIService {
  static const String _baseUrl = 'https://api.openai.com/v1/chat/completions';
  static const String _apiKey = 'YOUR_OPENAI_API_KEY'; // Replace with your API key

  static Future<String> getSleepAdvice(List<SleepEntry> weeklyEntries) async {
    if (weeklyEntries.isEmpty) {
      return 'No sleep data available for analysis. Start logging your sleep to get personalized advice!';
    }

    final sleepSummary = _generateSleepSummary(weeklyEntries);
    
    try {
      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_apiKey',
        },
        // role：system ⇒AI に役割を指示（睡眠の専門家として答える）
        // role：user ⇒実際の質問（週の睡眠データを渡す）
        body: jsonEncode({
          'model': 'gpt-4o-mini',
          'messages': [
            {
              'role': 'system',
              'content': 'You are a sleep health expert. Provide helpful, concise advice based on sleep patterns. Keep responses under 200 words and focus on actionable recommendations.'
            },
            {
              'role': 'user',
              'content': 'Based on this weekly sleep data, provide personalized sleep advice:\n\n$sleepSummary'
            }
          ],
          'max_tokens': 300,
          'temperature': 0.7,
        }),
      );

      // レスポンス処理
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['choices'][0]['message']['content'];
      } else {
        return 'Unable to get sleep advice at the moment. Please check your API key and try again.';
      }
    } catch (e) {
      return 'Error connecting to AI service. Please check your internet connection and try again.';
    }
  }

  // APIに送信する要約を生成する処理
  static String _generateSleepSummary(List<SleepEntry> entries) {
    final totalHours = entries.fold(0.0, (sum, entry) => sum + entry.sleepHours);
    final averageHours = totalHours / entries.length;
    
    final sleepTimes = entries.map((e) => e.sleepTime.hour + e.sleepTime.minute / 60.0).toList();
    final wakeTimes = entries.map((e) => e.wakeTime.hour + e.wakeTime.minute / 60.0).toList();
    
    final avgSleepTime = sleepTimes.reduce((a, b) => a + b) / sleepTimes.length;
    final avgWakeTime = wakeTimes.reduce((a, b) => a + b) / wakeTimes.length;

    return '''
Weekly Sleep Summary:
- Total entries: ${entries.length} days
- Average sleep duration: ${averageHours.toStringAsFixed(1)} hours
- Average bedtime: ${_formatTime(avgSleepTime)}
- Average wake time: ${_formatTime(avgWakeTime)}
- Sleep hours per day: ${entries.map((e) => e.sleepHours.toStringAsFixed(1)).join(', ')}
''';
  }

  static String _formatTime(double hours) {
    final hour = hours.floor();
    final minute = ((hours - hour) * 60).round();
    return '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';
  }
}