// Flutter の標準UI部品（Material Design）を使うためのインポート
import 'package:flutter/material.dart';
// ローカルDB初期化などを行うサービス
import 'services/database_service.dart';
// 最初に表示する画面を指定
import 'screens/home_screen.dart';

// アプリのエントリーポイント
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // DB初期化
  await DatabaseService.init();
  // アプリ本体を起動
  runApp(const SleepLogApp());
}

// アプリ全体のルートWidget（StatelessWidgetなので状態を持たない。各サービスで状態を管理。）
class SleepLogApp extends StatelessWidget {
  const SleepLogApp({super.key});

  @override
  Widget build(BuildContext context) {
    // アプリ全体に渡る設定（テーマ、ルート、タイトルなど）をまとめるウィジェット
    return MaterialApp(
      // アプリ名
      title: '睡眠ログ',
      // アプリの見た目設定
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color.fromARGB(255, 183, 58, 166)), // 画面全体のカラー
        useMaterial3: true, // Material3スタイルを使用
      ),
      // 最初に表示する画面
      home: const HomeScreen(),
      // デバッグビルド時の右上の「DEBUG」タグを非表示にする設定
      debugShowCheckedModeBanner: false,
    );
  }
}