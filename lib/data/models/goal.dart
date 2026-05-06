import 'package:hive/hive.dart';

part 'goal.g.dart';

enum GoalCategory { meditate, breathe, journal, moodlog }

@HiveType(typeId: 2)
class Goal extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String userId;

  @HiveField(2)
  final String title;

  @HiveField(3)
  final int categoryIndex;

  @HiveField(4)
  final int targetPerWeek;

  @HiveField(5)
  int currentWeekProgress;

  @HiveField(6)
  final DateTime createdAt;

  @HiveField(7)
  DateTime? archivedAt;

  @HiveField(8)
  DateTime? weekStartDate;

  Goal({
    required this.id,
    required this.userId,
    required this.title,
    required this.categoryIndex,
    required this.targetPerWeek,
    this.currentWeekProgress = 0,
    required this.createdAt,
    this.archivedAt,
    this.weekStartDate,
  });

  GoalCategory get category => GoalCategory.values[categoryIndex];
  bool get isActive => archivedAt == null;
  bool get isCompleted => currentWeekProgress >= targetPerWeek;

  Map<String, dynamic> toMap() => {
        'id': id,
        'userId': userId,
        'title': title,
        'categoryIndex': categoryIndex,
        'targetPerWeek': targetPerWeek,
        'currentWeekProgress': currentWeekProgress,
        'createdAt': createdAt.toIso8601String(),
        'archivedAt': archivedAt?.toIso8601String(),
        'weekStartDate': weekStartDate?.toIso8601String(),
      };

  factory Goal.fromMap(Map<String, dynamic> map, String userId) => Goal(
        id: map['id'] as String,
        userId: userId,
        title: map['title'] as String,
        categoryIndex: (map['categoryIndex'] as int?) ?? 0,
        targetPerWeek: (map['targetPerWeek'] as int?) ?? 3,
        currentWeekProgress: (map['currentWeekProgress'] as int?) ?? 0,
        createdAt: DateTime.parse(map['createdAt'] as String),
        archivedAt: map['archivedAt'] != null
            ? DateTime.parse(map['archivedAt'] as String)
            : null,
        weekStartDate: map['weekStartDate'] != null
            ? DateTime.parse(map['weekStartDate'] as String)
            : null,
      );
}
