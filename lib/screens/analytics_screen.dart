import 'package:flutter/material.dart';
// 折れ線グラフ
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../models/sleep_entry.dart';
import '../services/database_service.dart';

// 睡眠データをグラフで可視化する画面
class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  // 直近1週間の睡眠データ
  List<SleepEntry> _weeklyEntries = [];
  // 表示中の週
  DateTime _selectedWeek = DateTime.now();

  // 今週のデータをロード
  @override
  void initState() {
    super.initState();
    _loadWeeklyData();
  }

  // 選択した週の始まりの日付からデータを取得（月曜～日曜）
  void _loadWeeklyData() {
    final startOfWeek = _selectedWeek.subtract(Duration(days: _selectedWeek.weekday - 1));
    setState(() {
      _weeklyEntries = DatabaseService.getWeeklyEntries(startOfWeek);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sleep Analytics'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildWeekSelector(),
            const SizedBox(height: 24),
            _buildWeeklyStats(),
            const SizedBox(height: 24),
            const Text(
              'Weekly Sleep Chart',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: _weeklyEntries.isEmpty
                  ? const Center(
                      child: Text(
                        'No sleep data for this week',
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                    )
                  : _buildSleepChart(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWeekSelector() {
    final startOfWeek = _selectedWeek.subtract(Duration(days: _selectedWeek.weekday - 1));
    final endOfWeek = startOfWeek.add(const Duration(days: 6));

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              onPressed: () {
                setState(() {
                  _selectedWeek = _selectedWeek.subtract(const Duration(days: 7));
                });
                _loadWeeklyData();
              },
              icon: const Icon(Icons.chevron_left),
            ),
            Text(
              '${DateFormat('MMM dd').format(startOfWeek)} - ${DateFormat('MMM dd').format(endOfWeek)}',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            IconButton(
              onPressed: () {
                setState(() {
                  _selectedWeek = _selectedWeek.add(const Duration(days: 7));
                });
                _loadWeeklyData();
              },
              icon: const Icon(Icons.chevron_right),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWeeklyStats() {
    if (_weeklyEntries.isEmpty) {
      return const SizedBox.shrink();
    }

    final totalHours = _weeklyEntries.fold(0.0, (sum, entry) => sum + entry.sleepHours);
    final averageHours = totalHours / _weeklyEntries.length;
    final bestSleep = _weeklyEntries.reduce((a, b) => a.sleepHours > b.sleepHours ? a : b);
    final worstSleep = _weeklyEntries.reduce((a, b) => a.sleepHours < b.sleepHours ? a : b);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Weekly Summary',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatColumn('Average', '${averageHours.toStringAsFixed(1)}h'),
                _buildStatColumn('Best', '${bestSleep.sleepHours.toStringAsFixed(1)}h'),
                _buildStatColumn('Worst', '${worstSleep.sleepHours.toStringAsFixed(1)}h'),
                _buildStatColumn('Total', '${totalHours.toStringAsFixed(1)}h'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatColumn(String label, String value) {
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

  // グラフ生成処理
  Widget _buildSleepChart() {
    final spots = <FlSpot>[];
    for (int i = 0; i < _weeklyEntries.length; i++) {
      // x軸（日付）、y軸（睡眠時間）にデータを渡す
      spots.add(FlSpot(i.toDouble(), _weeklyEntries[i].sleepHours));
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: LineChart(
          LineChartData(
            gridData: const FlGridData(show: true),
            titlesData: FlTitlesData(
              leftTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 40,
                  getTitlesWidget: (value, meta) {
                    return Text('${value.toInt()}h');
                  },
                ),
              ),
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  getTitlesWidget: (value, meta) {
                    if (value.toInt() < _weeklyEntries.length) {
                      return Text(
                        DateFormat('E').format(_weeklyEntries[value.toInt()].date),
                      );
                    }
                    return const Text('');
                  },
                ),
              ),
              topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            ),
            borderData: FlBorderData(show: true),
            minX: 0,
            maxX: (_weeklyEntries.length - 1).toDouble(),
            minY: 0,
            maxY: 12,
            lineBarsData: [
              LineChartBarData(
                spots: spots,
                isCurved: true,
                color: Theme.of(context).primaryColor,
                barWidth: 3,
                dotData: const FlDotData(show: true),
                belowBarData: BarAreaData(
                  show: true,
                  color: Theme.of(context).primaryColor.withOpacity(0.3),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}