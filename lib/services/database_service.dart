import 'package:hive_flutter/hive_flutter.dart';
import '../models/sleep_entry.dart';

// ローカルにデータを保存/読み書きする処理
class DatabaseService {
  // 保存場所（箱）の名前
  static const String _boxName = 'sleep_entries';
  // SleepEntry 型のデータを保存する箱
  static Box<SleepEntry>? _box;

  // 初期化処理
  static Future<void> init() async {
    // Hive を初期化
    await Hive.initFlutter();
    // SleepEntry モデルを登録
    Hive.registerAdapter(SleepEntryAdapter());
    // 箱を開く
    _box = await Hive.openBox<SleepEntry>(_boxName);
  }

  static Box<SleepEntry> get box {
    if (_box == null) {
      throw Exception('Database not initialized. Call init() first.');
    }
    return _box!;
  }

  // SleepEntryモデルへの追加・更新処理
  static Future<void> addSleepEntry(SleepEntry entry) async {
    // 日付をキーにする
    final key = entry.date.toIso8601String().split('T')[0];
    await box.put(key, entry);
  }

  // SleepEntryモデルからの取得処理
  static SleepEntry? getSleepEntry(DateTime date) {
    final key = date.toIso8601String().split('T')[0];
    return box.get(key);
  }

  // SleepEntryモデルからの全件取得処理
  static List<SleepEntry> getAllEntries() {
    return box.values.toList()..sort((a, b) => a.date.compareTo(b.date));
  }

  // SleepEntryモデルからの週単位でのデータ取得処理
  static List<SleepEntry> getWeeklyEntries(DateTime startDate) {
    final endDate = startDate.add(const Duration(days: 7));
    return box.values
        .where((entry) =>
            entry.date.isAfter(startDate.subtract(const Duration(days: 1))) &&
            entry.date.isBefore(endDate))
        .toList()
      ..sort((a, b) => a.date.compareTo(b.date));
  }

  // SleepEntryモデルのデータ削除処理
  static Future<void> deleteSleepEntry(DateTime date) async {
    final key = date.toIso8601String().split('T')[0];
    await box.delete(key);
  }
}