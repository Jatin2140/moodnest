import 'package:hive/hive.dart';

part 'reminder.g.dart';

enum ReminderType { mood, meditate, journal }

@HiveType(typeId: 3)
class Reminder extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String userId;

  @HiveField(2)
  final int typeIndex;

  @HiveField(3)
  final String time; // HH:mm

  @HiveField(4)
  final List<int> daysOfWeek; // 1=Mon..7=Sun

  @HiveField(5)
  bool enabled;

  Reminder({
    required this.id,
    required this.userId,
    required this.typeIndex,
    required this.time,
    required this.daysOfWeek,
    this.enabled = true,
  });

  ReminderType get type => ReminderType.values[typeIndex];

  String get label => switch (type) {
        ReminderType.mood => 'Mood check-in',
        ReminderType.meditate => 'Meditation',
        ReminderType.journal => 'Journal entry',
      };

  Map<String, dynamic> toMap() => {
        'id': id,
        'userId': userId,
        'typeIndex': typeIndex,
        'time': time,
        'daysOfWeek': daysOfWeek,
        'enabled': enabled,
      };

  factory Reminder.fromMap(Map<String, dynamic> map, String userId) => Reminder(
        id: map['id'] as String,
        userId: userId,
        typeIndex: (map['typeIndex'] as int?) ?? 0,
        time: map['time'] as String? ?? '09:00',
        daysOfWeek: List<int>.from(map['daysOfWeek'] ?? [1, 2, 3, 4, 5]),
        enabled: (map['enabled'] as bool?) ?? true,
      );
}
