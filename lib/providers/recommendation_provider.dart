import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../data/models/mood_entry.dart';
import '../data/repositories/content_repository.dart';
import '../logic/recommender/mood_recommender.dart';
import '../core/theme/app_colors.dart';
import '../core/utils/date_x.dart';

class RecommendationProvider extends ChangeNotifier {
  final ContentRepository _content;
  final FirebaseFirestore _db;
  final String uid;

  List<Recommendation> _recommendations = [];
  Map<String, CompletionRecord> _history = {};
  bool _loading = false;

  RecommendationProvider({
    required this.uid,
    ContentRepository? content,
    FirebaseFirestore? db,
  })  : _content = content ?? ContentRepository(),
        _db = db ?? FirebaseFirestore.instance;

  List<Recommendation> get recommendations => _recommendations;
  bool get isLoading => _loading;

  Future<void> refresh({
    required MoodType currentMood,
    required List<MoodEntry> last7Moods,
  }) async {
    _loading = true;
    notifyListeners();

    await _loadHistory();

    final meditations = await _content.getMeditations();
    final breathing = await _content.getBreathingPatterns();
    final prompts = await _content.getJournalPrompts();

    final catalog = [
      ...meditations.map((m) => RecommendableContent(
            id: m.id,
            title: m.title,
            description: m.description,
            type: ContentType.meditation,
            moodFit: m.moodFit,
            idealTimeBands: m.idealTimeBands,
            intensity: m.intensity,
            tags: m.tags,
            raw: m,
          )),
      ...breathing.map((b) => RecommendableContent(
            id: b.id,
            title: b.name,
            description: b.description,
            type: ContentType.breathing,
            moodFit: b.moodFit,
            idealTimeBands: b.idealTimeBands,
            intensity: b.intensity,
            tags: b.tags,
            raw: b,
          )),
      ...prompts.take(5).map((p) => RecommendableContent(
            id: p['id'] as String,
            title: 'Journal prompt',
            description: p['text'] as String,
            type: ContentType.journalPrompt,
            moodFit: const {
              'joyful': 0.7,
              'calm': 0.7,
              'neutral': 0.8,
              'low': 0.9,
              'stressed': 0.8
            },
            idealTimeBands: const ['morning', 'afternoon', 'evening', 'night'],
            intensity: 0.3,
            tags: const ['journal', 'reflection'],
            raw: p,
          )),
    ];

    _recommendations = MoodRecommender.recommend(
      currentMood: currentMood,
      last7Moods: last7Moods,
      timeOfDay: DateTime.now().timeLabel,
      completionHistory: _history,
      catalog: catalog,
    );

    _loading = false;
    notifyListeners();
  }

  Future<void> recordCompletion(String contentId, double ratio) async {
    final prev = _history[contentId];
    _history[contentId] = CompletionRecord(
      playCount: (prev?.playCount ?? 0) + 1,
      lastCompleted: DateTime.now(),
      completedRatio: ratio,
    );
    try {
      await _db
          .collection('users')
          .doc(uid)
          .collection('events')
          .add({
        'contentId': contentId,
        'completedAt': DateTime.now().toIso8601String(),
        'ratio': ratio,
      });
    } catch (_) {}
  }

  Future<void> _loadHistory() async {
    try {
      final snap = await _db
          .collection('users')
          .doc(uid)
          .collection('events')
          .orderBy('completedAt', descending: true)
          .limit(100)
          .get();

      final grouped = <String, List<Map<String, dynamic>>>{};
      for (final doc in snap.docs) {
        final d = doc.data();
        final id = d['contentId'] as String;
        grouped.putIfAbsent(id, () => []).add(d);
      }

      _history = grouped.map((id, events) {
        DateTime? last;
        if (events.first['completedAt'] != null) {
          last = DateTime.tryParse(events.first['completedAt'] as String);
        }
        return MapEntry(
          id,
          CompletionRecord(
            playCount: events.length,
            lastCompleted: last,
            completedRatio: (events.first['ratio'] as num?)?.toDouble() ?? 0.0,
          ),
        );
      });
    } catch (_) {}
  }
}
