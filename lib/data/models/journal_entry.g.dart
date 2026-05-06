// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'journal_entry.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class JournalEntryAdapter extends TypeAdapter<JournalEntry> {
  @override
  final int typeId = 1;

  @override
  JournalEntry read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return JournalEntry(
      id: fields[0] as String,
      userId: fields[1] as String,
      promptId: fields[2] as String?,
      bodyMarkdown: fields[3] as String,
      moodIndex: fields[4] as int?,
      wordCount: fields[5] as int,
      createdAt: fields[6] as DateTime,
      pendingSync: fields[7] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, JournalEntry obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.userId)
      ..writeByte(2)
      ..write(obj.promptId)
      ..writeByte(3)
      ..write(obj.bodyMarkdown)
      ..writeByte(4)
      ..write(obj.moodIndex)
      ..writeByte(5)
      ..write(obj.wordCount)
      ..writeByte(6)
      ..write(obj.createdAt)
      ..writeByte(7)
      ..write(obj.pendingSync);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is JournalEntryAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
