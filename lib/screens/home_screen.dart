import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/sleep_entry.dart';
import '../services/database_service.dart';
import '../widgets/sleep_input_dialog.dart';
import 'analytics_screen.dart';
import 'advice_screen.dart';

// アプリのメイン画面（ホーム）
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // 直近7日分のデータ
  List<SleepEntry> _recentEntries = [];

  @override
  void initState() {
    super.initState();
    _loadRecentEntries();
  }

  // 直近7日分のデータを取得する処理（逆順）
  void _loadRecentEntries() {
    setState(() {
      _recentEntries = DatabaseService.getAllEntries()
          .reversed
          .take(7)
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('睡眠ログ'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildQuickStats(),
            const SizedBox(height: 24),
            Row(
              children: [
                const Text(
                  'Recent Sleep Logs',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const AnalyticsScreen()),
                    );
                  },
                  child: const Text('View Analytics'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: _recentEntries.isEmpty
                  ? const Center(
                      child: Text(
                        'No sleep logs yet.\nTap the + button to add your first entry!',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                    )
                  : ListView.builder(
                      itemCount: _recentEntries.length,
                      itemBuilder: (context, index) {
                        final entry = _recentEntries[index];
                        return _buildSleepEntryCard(entry);
                      },
                    ),
            ),
          ],
        ),
      ),
      // 「+」ボタン
      floatingActionButton: FloatingActionButton(
        onPressed: _showSleepInputDialog,
        child: const Icon(Icons.add),
      ),
      // 画面下部のナビゲーションバー
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.analytics), label: 'Analytics'),
          BottomNavigationBarItem(icon: Icon(Icons.lightbulb), label: 'Advice'),
        ],
        onTap: (index) {
          if (index == 1) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const AnalyticsScreen()),
            );
          } else if (index == 2) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const AdviceScreen()),
            );
          }
        },
      ),
    );
  }

  Widget _buildQuickStats() {
    if (_recentEntries.isEmpty) {
      return const SizedBox.shrink();
    }

    final lastEntry = _recentEntries.first;
    final weeklyEntries = DatabaseService.getWeeklyEntries(
      DateTime.now().subtract(const Duration(days: 7)),
    );
    final avgSleep = weeklyEntries.isEmpty
        ? 0.0
        : weeklyEntries.fold(0.0, (sum, entry) => sum + entry.sleepHours) /
            weeklyEntries.length;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Quick Stats',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem(
                  'Last Sleep',
                  '${lastEntry.sleepHours.toStringAsFixed(1)}h',
                  Icons.bedtime,
                ),
                _buildStatItem(
                  'Weekly Avg',
                  '${avgSleep.toStringAsFixed(1)}h',
                  Icons.analytics,
                ),
                _buildStatItem(
                  'Total Logs',
                  '${DatabaseService.getAllEntries().length}',
                  Icons.calendar_today,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, size: 24, color: Theme.of(context).primaryColor),
        const SizedBox(height: 4),
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

  Widget _buildSleepEntryCard(SleepEntry entry) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Theme.of(context).primaryColor,
          child: Text(
            DateFormat('dd').format(entry.date),
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
        title: Text(DateFormat('EEEE, MMM dd').format(entry.date)),
        subtitle: Text(
          'Sleep: ${DateFormat('HH:mm').format(entry.sleepTime)} - '
          'Wake: ${DateFormat('HH:mm').format(entry.wakeTime)}',
        ),
        trailing: Text(
          '${entry.sleepHours.toStringAsFixed(1)}h',
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        onTap: () => _editSleepEntry(entry),
      ),
    );
  }

  // 「+」もしくは一覧を押下したときに開くダイアログの処理
  void _showSleepInputDialog() {
    showDialog(
      context: context,
      builder: (context) => SleepInputDialog(
        onSave: (entry) {
          // 入力値を保存
          DatabaseService.addSleepEntry(entry);
          // 保存後に再読み込み
          _loadRecentEntries();
        },
      ),
    );
  }

  void _editSleepEntry(SleepEntry entry) {
    showDialog(
      context: context,
      builder: (context) => SleepInputDialog(
        existingEntry: entry,
        onSave: (updatedEntry) {
          DatabaseService.addSleepEntry(updatedEntry);
          _loadRecentEntries();
        },
      ),
    );
  }
}