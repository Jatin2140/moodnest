import 'package:hive/hive.dart';

part 'journal_entry.g.dart';

@HiveType(typeId: 1)
class JournalEntry extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String userId;

  @HiveField(2)
  final String? promptId;

  @HiveField(3)
  final String bodyMarkdown;

  @HiveField(4)
  final int? moodIndex;

  @HiveField(5)
  final int wordCount;

  @HiveField(6)
  final DateTime createdAt;

  @HiveField(7)
  bool pendingSync;

  JournalEntry({
    required this.id,
    required this.userId,
    this.promptId,
    required this.bodyMarkdown,
    this.moodIndex,
    required this.wordCount,
    required this.createdAt,
    this.pendingSync = false,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'userId': userId,
        'promptId': promptId,
        'bodyMarkdown': bodyMarkdown,
        'moodIndex': moodIndex,
        'wordCount': wordCount,
        'createdAt': createdAt.toIso8601String(),
      };

  factory JournalEntry.fromMap(Map<String, dynamic> map, String userId) {
    return JournalEntry(
      id: map['id'] as String,
      userId: userId,
      promptId: map['promptId'] as String?,
      bodyMarkdown: map['bodyMarkdown'] as String? ?? '',
      moodIndex: map['moodIndex'] as int?,
      wordCount: (map['wordCount'] as int?) ?? 0,
      createdAt: DateTime.parse(map['createdAt'] as String),
    );
  }

  JournalEntry copyWith({
    String? bodyMarkdown,
    String? promptId,
    int? moodIndex,
    int? wordCount,
  }) {
    return JournalEntry(
      id: id,
      userId: userId,
      promptId: promptId ?? this.promptId,
      bodyMarkdown: bodyMarkdown ?? this.bodyMarkdown,
      moodIndex: moodIndex ?? this.moodIndex,
      wordCount: wordCount ?? this.wordCount,
      createdAt: createdAt,
      pendingSync: pendingSync,
    );
  }
}
