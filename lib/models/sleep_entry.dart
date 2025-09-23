// 軽量でシンプルなローカルDB（SQLiteの代わりに使える）
import 'package:hive/hive.dart';
// Hive が使う自動生成コードを取り込む宣言（build_runnerで自動生成される）
part 'sleep_entry.g.dart';

// 睡眠データ1件分の構造（モデルクラス）

// このクラスを Hive で保存可能な「型」として登録するためのアノテーション
// typeId は一意のID。アプリ内の他のモデルと被らないようにする。他にモデルを追加するときは 1, 2, ... と増やす。
@HiveType(typeId: 0)
class SleepEntry extends HiveObject {
  // @HiveField(番号) は、Hiveがデータをバイナリ保存するときの「フィールド番号」
  @HiveField(0)
  DateTime date; // その日の睡眠ログの日付

  @HiveField(1)
  DateTime sleepTime; // 寝た時間

  @HiveField(2)
  DateTime wakeTime; // 起きた時間

  // コンストラクタ。新しい SleepEntry を作るときに必須の情報を渡す。
  SleepEntry({
    required this.date,
    required this.sleepTime,
    required this.wakeTime,
  });

  // 睡眠時間を計算するメソッド
  Duration get sleepDuration {
    // 起きた時間 < 寝た時間
    if (wakeTime.isBefore(sleepTime)) {
      // +1日して計算
      final nextDayWakeTime = wakeTime.add(const Duration(days: 1));
      return nextDayWakeTime.difference(sleepTime);
    }
    return wakeTime.difference(sleepTime);
  }

  // Duration を「時間数（小数点付き）」に変換するプロパティ（例：7時間30分 → 7.5）
  double get sleepHours => sleepDuration.inMinutes / 60.0;
}