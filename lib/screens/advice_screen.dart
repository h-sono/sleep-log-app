import 'package:flutter/material.dart';
import '../models/sleep_entry.dart';
import '../services/database_service.dart';
import '../services/openai_service.dart';

// AIによる睡眠アドバイス画面
// データの取得・更新が必要なので StatefulWidgetを使用
class AdviceScreen extends StatefulWidget {
  const AdviceScreen({super.key});

  @override
  State<AdviceScreen> createState() => _AdviceScreenState();
}

class _AdviceScreenState extends State<AdviceScreen> {
  // AIから取得したアドバイスを表示する文字列
  String _advice = '';
  // API呼び出し中かどうかを管理
  bool _isLoading = false;
  // 直近1週間の睡眠データ
  List<SleepEntry> _weeklyEntries = [];

  // 起動時に _loadWeeklyData() を呼び出してデータを準備
  @override
  void initState() {
    super.initState();
    _loadWeeklyData();
  }

  void _loadWeeklyData() {
    final startOfWeek = DateTime.now().subtract(const Duration(days: 7));
    setState(() {
      _weeklyEntries = DatabaseService.getWeeklyEntries(startOfWeek);
    });
  }

  // OpenAIService 経由で AI アドバイスを取得する処理
  // Future：非同期なのでasync、awaitを使用している。
  Future<void> _getAdvice() async {
    setState(() {
      // ローディング中はボタンを無効化し、スピナーを表示
      _isLoading = true;
    });

    try {
      final advice = await OpenAIService.getSleepAdvice(_weeklyEntries);
      setState(() {
        _advice = advice;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _advice = 'Error getting sleep advice. Please try again later.';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // アプリ上部のブロック
      appBar: AppBar(
        title: const Text('Sleep Advice'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      // アプリのボディ部分
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildWeeklySummary(),
            const SizedBox(height: 24),
            Row(
              children: [
                const Text(
                  'AI Sleep Advice',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                ElevatedButton.icon(
                  onPressed: _isLoading ? null : _getAdvice,
                  icon: _isLoading
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.refresh),
                  label: Text(_isLoading ? 'Getting Advice...' : 'Get Advice'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: _advice.isEmpty
                      ? const Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.lightbulb_outline,
                                size: 64,
                                color: Colors.grey,
                              ),
                              SizedBox(height: 16),
                              Text(
                                'Tap "Get Advice" to receive personalized sleep recommendations based on your weekly sleep patterns.',
                                textAlign: TextAlign.center,
                                style: TextStyle(fontSize: 16, color: Colors.grey),
                              ),
                            ],
                          ),
                        )
                      : SingleChildScrollView(
                          child: Text(
                            _advice,
                            style: const TextStyle(fontSize: 16, height: 1.5),
                          ),
                        ),
                ),
              ),
            ),
            if (_weeklyEntries.isEmpty)
              Container(
                padding: const EdgeInsets.all(16),
                margin: const EdgeInsets.only(top: 16),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.orange.withOpacity(0.3)),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.info_outline, color: Colors.orange),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Add some sleep logs to get personalized advice!',
                        style: TextStyle(color: Colors.orange),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildWeeklySummary() {
    if (_weeklyEntries.isEmpty) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Text(
            'No sleep data available for the past week.',
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
        ),
      );
    }

    final totalHours = _weeklyEntries.fold(0.0, (sum, entry) => sum + entry.sleepHours);
    final averageHours = totalHours / _weeklyEntries.length;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'This Week\'s Sleep Summary',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildSummaryItem('Days Logged', '${_weeklyEntries.length}'),
                _buildSummaryItem('Average Sleep', '${averageHours.toStringAsFixed(1)}h'),
                _buildSummaryItem('Total Sleep', '${totalHours.toStringAsFixed(1)}h'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryItem(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: Colors.grey),
        ),
      ],
    );
  }
}