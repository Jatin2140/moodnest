// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'goal.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class GoalAdapter extends TypeAdapter<Goal> {
  @override
  final int typeId = 2;

  @override
  Goal read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Goal(
      id: fields[0] as String,
      userId: fields[1] as String,
      title: fields[2] as String,
      categoryIndex: fields[3] as int,
      targetPerWeek: fields[4] as int,
      currentWeekProgress: fields[5] as int,
      createdAt: fields[6] as DateTime,
      archivedAt: fields[7] as DateTime?,
      weekStartDate: fields[8] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, Goal obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.userId)
      ..writeByte(2)
      ..write(obj.title)
      ..writeByte(3)
      ..write(obj.categoryIndex)
      ..writeByte(4)
      ..write(obj.targetPerWeek)
      ..writeByte(5)
      ..write(obj.currentWeekProgress)
      ..writeByte(6)
      ..write(obj.createdAt)
      ..writeByte(7)
      ..write(obj.archivedAt)
      ..writeByte(8)
      ..write(obj.weekStartDate);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GoalAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
