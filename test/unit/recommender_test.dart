import 'package:flutter_test/flutter_test.dart';
import 'package:moodnest/core/theme/app_colors.dart';
import 'package:moodnest/data/models/mood_entry.dart';
import 'package:moodnest/logic/recommender/mood_recommender.dart';

MoodEntry _entry(int valence, {int daysAgo = 0}) => MoodEntry(
      id: 'e$valence$daysAgo',
      userId: 'u',
      moodIndex: MoodPalette.fromValence(valence).index,
      valence: valence,
      createdAt: DateTime.now().subtract(Duration(days: daysAgo)),
    );

RecommendableContent _content({
  required String id,
  required String moodName,
  double moodFitVal = 0.8,
  double intensity = 0.3,
  List<String> timeBands = const ['morning', 'afternoon', 'evening', 'night'],
  List<String> tags = const ['calm'],
}) =>
    RecommendableContent(
      id: id,
      title: id,
      description: '',
      type: ContentType.meditation,
      moodFit: {moodName: moodFitVal, 'joyful': 0.5, 'stressed': 0.5, 'low': 0.5, 'neutral': 0.5},
      idealTimeBands: timeBands,
      intensity: intensity,
      tags: tags,
      raw: null,
    );

void main() {
  group('MoodRecommender', () {
    test('1 – returns calming items (low intensity) when 7-day slope is negative', () {
      // Moods descending: 5, 4, 3, 2, 1 → slope < 0
      final moods = [
        _entry(5, daysAgo: 6),
        _entry(4, daysAgo: 5),
        _entry(3, daysAgo: 4),
        _entry(2, daysAgo: 3),
        _entry(1, daysAgo: 2),
      ];

      final catalog = [
        _content(id: 'calming', moodName: 'low', intensity: 0.1),
        _content(id: 'energiser', moodName: 'low', intensity: 0.9),
      ];

      final recs = MoodRecommender.recommend(
        currentMood: MoodType.low,
        last7Moods: moods,
        timeOfDay: 'evening',
        completionHistory: {},
        catalog: catalog,
      );

      expect(recs.first.content.id, 'calming');
    });

    test('2 – item played in last 24h is penalised below unplayed item', () {
      final catalog = [
        _content(id: 'fresh', moodName: 'calm', moodFitVal: 0.6),
        _content(id: 'stale', moodName: 'calm', moodFitVal: 0.8),
      ];

      final history = {
        'stale': CompletionRecord(
          playCount: 3,
          lastCompleted: DateTime.now().subtract(const Duration(hours: 2)),
          completedRatio: 1.0,
        ),
      };

      final recs = MoodRecommender.recommend(
        currentMood: MoodType.calm,
        last7Moods: [],
        timeOfDay: 'morning',
        completionHistory: history,
        catalog: catalog,
      );

      expect(recs.first.content.id, 'fresh');
    });

    test('3 – time-of-day mismatch demotes item below time-matched item', () {
      final catalog = [
        _content(id: 'night_only', moodName: 'neutral', timeBands: ['night']),
        _content(id: 'morning_match', moodName: 'neutral', timeBands: ['morning']),
      ];

      final recs = MoodRecommender.recommend(
        currentMood: MoodType.neutral,
        last7Moods: [],
        timeOfDay: 'morning',
        completionHistory: {},
        catalog: catalog,
      );

      expect(recs.first.content.id, 'morning_match');
    });

    test('4 – variety bonus prevents same-tag items dominating top-3', () {
      // 3 identical-tag items vs 1 different-tag item with slightly lower moodFit
      final catalog = [
        _content(id: 'a', moodName: 'joyful', moodFitVal: 0.9, tags: ['sleep']),
        _content(id: 'b', moodName: 'joyful', moodFitVal: 0.85, tags: ['sleep']),
        _content(id: 'c', moodName: 'joyful', moodFitVal: 0.8, tags: ['sleep']),
        _content(id: 'd', moodName: 'joyful', moodFitVal: 0.7, tags: ['focus']),
      ];

      // Simulate 'a' recently played so 'sleep' tag is recent
      final history = {
        'a': CompletionRecord(
          playCount: 1,
          lastCompleted: DateTime.now().subtract(const Duration(hours: 10)),
          completedRatio: 1.0,
        ),
      };

      final recs = MoodRecommender.recommend(
        currentMood: MoodType.joyful,
        last7Moods: [],
        timeOfDay: 'afternoon',
        completionHistory: history,
        catalog: catalog,
        topN: 3,
      );

      // 'd' (different tag) should appear somewhere in top-3
      final ids = recs.map((r) => r.content.id).toList();
      expect(ids.contains('d'), isTrue);
    });

    test('5 – empty history falls back to moodFit ordering', () {
      final catalog = [
        _content(id: 'best', moodName: 'stressed', moodFitVal: 0.95),
        _content(id: 'ok', moodName: 'stressed', moodFitVal: 0.5),
        _content(id: 'low', moodName: 'stressed', moodFitVal: 0.2),
      ];

      final recs = MoodRecommender.recommend(
        currentMood: MoodType.stressed,
        last7Moods: [],
        timeOfDay: 'afternoon',
        completionHistory: {},
        catalog: catalog,
      );

      expect(recs.first.content.id, 'best');
    });
  });
}
