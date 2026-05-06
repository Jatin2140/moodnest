import 'package:hive/hive.dart';
import '../../core/theme/app_colors.dart';

part 'mood_entry.g.dart';

@HiveType(typeId: 0)
class MoodEntry extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String userId;

  @HiveField(2)
  final int moodIndex; // MoodType index

  @HiveField(3)
  final int valence; // 1-5

  @HiveField(4)
  final String? note;

  @HiveField(5)
  final List<String> tags;

  @HiveField(6)
  final DateTime createdAt;

  @HiveField(7)
  bool pendingSync;

  MoodEntry({
    required this.id,
    required this.userId,
    required this.moodIndex,
    required this.valence,
    this.note,
    this.tags = const [],
    required this.createdAt,
    this.pendingSync = false,
  });

  MoodType get mood => MoodType.values[moodIndex];

  Map<String, dynamic> toMap() => {
        'id': id,
        'userId': userId,
        'moodIndex': moodIndex,
        'valence': valence,
        'note': note,
        'tags': tags,
        'createdAt': createdAt.toIso8601String(),
      };

  factory MoodEntry.fromMap(Map<String, dynamic> map, String userId) {
    return MoodEntry(
      id: map['id'] as String,
      userId: userId,
      moodIndex: (map['moodIndex'] as int?) ?? 2,
      valence: (map['valence'] as int?) ?? 3,
      note: map['note'] as String?,
      tags: List<String>.from(map['tags'] ?? []),
      createdAt: DateTime.parse(map['createdAt'] as String),
    );
  }
}
