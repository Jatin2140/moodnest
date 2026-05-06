// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'reminder.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ReminderAdapter extends TypeAdapter<Reminder> {
  @override
  final int typeId = 3;

  @override
  Reminder read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Reminder(
      id: fields[0] as String,
      userId: fields[1] as String,
      typeIndex: fields[2] as int,
      time: fields[3] as String,
      daysOfWeek: (fields[4] as List).cast<int>(),
      enabled: fields[5] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, Reminder obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.userId)
      ..writeByte(2)
      ..write(obj.typeIndex)
      ..writeByte(3)
      ..write(obj.time)
      ..writeByte(4)
      ..write(obj.daysOfWeek)
      ..writeByte(5)
      ..write(obj.enabled);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ReminderAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
