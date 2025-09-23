// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sleep_entry.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

// Hiveが SleepEntry を保存/読み込みするときに使う「アダプター」（本ファイルはbuild_runnerで生成するファイル）
class SleepEntryAdapter extends TypeAdapter<SleepEntry> {
  @override
  final int typeId = 0;

  // 保存されているデータを バイナリから読み取って SleepEntry に変換する処理
  @override
  SleepEntry read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SleepEntry(
      date: fields[0] as DateTime,
      sleepTime: fields[1] as DateTime,
      wakeTime: fields[2] as DateTime,
    );
  }

  // SleepEntry のデータを バイナリ形式で保存する処理
  @override
  void write(BinaryWriter writer, SleepEntry obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.date)
      ..writeByte(1)
      ..write(obj.sleepTime)
      ..writeByte(2)
      ..write(obj.wakeTime);
  }

  @override
  int get hashCode => typeId.hashCode;

  // Hiveがアダプターを識別できるように、== の比較方法も定義
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SleepEntryAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
