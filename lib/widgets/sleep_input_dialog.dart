import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/sleep_entry.dart';

/// ユーザーがデータを入力するUI
class SleepInputDialog extends StatefulWidget {
  // すでにあるデータ。編集時に使う。null の場合は「新規作成モード」。
  final SleepEntry? existingEntry;
  // 保存ボタンを押したときに呼ばれるコールバック
  final Function(SleepEntry) onSave;

  const SleepInputDialog({
    super.key,
    this.existingEntry,
    required this.onSave,
  });

  @override
  State<SleepInputDialog> createState() => _SleepInputDialogState();
}

class _SleepInputDialogState extends State<SleepInputDialog> {
  late DateTime _selectedDate;
  late TimeOfDay _sleepTime;
  late TimeOfDay _wakeTime;

  @override
  void initState() {
    super.initState();
    if (widget.existingEntry != null) {
      // 編集モードなら既存データを初期値に
      _selectedDate = widget.existingEntry!.date;
      _sleepTime = TimeOfDay.fromDateTime(widget.existingEntry!.sleepTime);
      _wakeTime = TimeOfDay.fromDateTime(widget.existingEntry!.wakeTime);
    } else {
      // 新規モードならデフォルト値をセット
      _selectedDate = DateTime.now();
      _sleepTime = const TimeOfDay(hour: 22, minute: 0);
      _wakeTime = const TimeOfDay(hour: 7, minute: 0);
    }
  }

  @override
  Widget build(BuildContext context) {
    // 新規・編集ダイアログ
    return AlertDialog(
      title: Text(widget.existingEntry != null ? 'Edit Sleep Log' : 'Add Sleep Log'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 日付
          ListTile(
            leading: const Icon(Icons.calendar_today),
            title: const Text('Date'),
            subtitle: Text(DateFormat('EEEE, MMM dd, yyyy').format(_selectedDate)),
            onTap: _selectDate,
          ),
          // 寝た時間
          ListTile(
            leading: const Icon(Icons.bedtime),
            title: const Text('Sleep Time'),
            subtitle: Text(_sleepTime.format(context)),
            onTap: () => _selectTime(true),
          ),
          // 起きた時間
          ListTile(
            leading: const Icon(Icons.wb_sunny),
            title: const Text('Wake Time'),
            subtitle: Text(_wakeTime.format(context)),
            onTap: () => _selectTime(false),
          ),
        ],
      ),
      actions: [
        // キャンセルボタンのアクション
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        // 保存ボタンのアクション
        ElevatedButton(
          onPressed: _saveSleepEntry,
          child: const Text('Save'),
        ),
      ],
    );
  }

  /// 日付の選択 
  Future<void> _selectDate() async {
    // Flutter標準のカレンダーUI
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now(),
    );
    if (date != null) {
      setState(() {
        _selectedDate = date;
      });
    }
  }

  /// 時間の選択
  Future<void> _selectTime(bool isSleepTime) async {
    // 時計形式のダイアログ
    final time = await showTimePicker(
      context: context,
      initialTime: isSleepTime ? _sleepTime : _wakeTime,
    );

    if (time != null) {
      setState(() {
        if (isSleepTime) {
          _sleepTime = time;
        } else {
          _wakeTime = time;
        }
      });
    }
  }

  /// 保存処理
  void _saveSleepEntry() {
    final sleepDateTime = DateTime(
      _selectedDate.year,
      _selectedDate.month,
      _selectedDate.day,
      _sleepTime.hour,
      _sleepTime.minute,
    );

    final wakeDateTime = DateTime(
      _selectedDate.year,
      _selectedDate.month,
      _selectedDate.day,
      _wakeTime.hour,
      _wakeTime.minute,
    );

    // 起床時間が就寝時間より前 → 翌日とみなす
    final adjustedWakeTime = wakeDateTime.isBefore(sleepDateTime)
        ? wakeDateTime.add(const Duration(days: 1))
        : wakeDateTime;

    final entry = SleepEntry(
      date: _selectedDate,
      sleepTime: sleepDateTime,
      wakeTime: adjustedWakeTime,
    );

    // 呼び出し元に返す
    widget.onSave(entry);
    // ダイアログを閉じる
    Navigator.of(context).pop();
  }
}