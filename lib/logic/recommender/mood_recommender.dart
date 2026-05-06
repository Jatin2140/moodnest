import '../../data/models/mood_entry.dart';
import '../../core/theme/app_colors.dart';

enum ContentType { meditation, breathing, journalPrompt }

class RecommendableContent {
  final String id;
  final String title;
  final String description;
  final ContentType type;
  final Map<String, double> moodFit; // mood name -> 0..1
  final List<String> idealTimeBands;
  final double intensity;
  final List<String> tags;
  final dynamic raw;

  const RecommendableContent({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    required this.moodFit,
    required this.idealTimeBands,
    required this.intensity,
    required this.tags,
    required this.raw,
  });
}

class CompletionRecord {
  final int playCount;
  final DateTime? lastCompleted;
  final double completedRatio;

  const CompletionRecord({
    this.playCount = 0,
    this.lastCompleted,
    this.completedRatio = 0.0,
  });
}

class Recommendation {
  final RecommendableContent content;
  final double score;
  final String whyExplanation;

  const Recommendation({
    required this.content,
    required this.score,
    required this.whyExplanation,
  });
}

class MoodRecommender {
  // Pure function — no Flutter imports, fully unit-testable.
  static List<Recommendation> recommend({
    required MoodType currentMood,
    required List<MoodEntry> last7Moods,
    required String timeOfDay,
    required Map<String, CompletionRecord> completionHistory,
    required List<RecommendableContent> catalog,
    int topN = 3,
  }) {
    if (catalog.isEmpty) return [];

    final currentMoodName = MoodPalette.label[currentMood]!.toLowerCase();
    final trendSlope = _trendSlope(last7Moods);
    final recentTags = _recentTags(completionHistory, catalog);

    final scored = catalog.map((item) {
      final score = _score(
        item: item,
        currentMoodName: currentMoodName,
        trendSlope: trendSlope,
        timeOfDay: timeOfDay,
        history: completionHistory[item.id],
        recentTags: recentTags,
      );
      final why = _explain(
        item: item,
        currentMoodName: currentMoodName,
        trendSlope: trendSlope,
        timeOfDay: timeOfDay,
        history: completionHistory[item.id],
      );
      return Recommendation(content: item, score: score, whyExplanation: why);
    }).toList()
      ..sort((a, b) => b.score.compareTo(a.score));

    return scored.take(topN).toList();
  }

  static double _score({
    required RecommendableContent item,
    required String currentMoodName,
    required double trendSlope,
    required String timeOfDay,
    required CompletionRecord? history,
    required Set<String> recentTags,
  }) {
    double score = 0;

    // 1.0 * baseline mood fit
    score += 1.0 * (item.moodFit[currentMoodName] ?? 0.5);

    // 0.6 * trend adjustment: downward slope → prefer calming (intensity < 0.4)
    if (trendSlope < -0.1) {
      score += 0.6 * (1.0 - item.intensity.clamp(0.0, 1.0));
    } else if (trendSlope > 0.1) {
      score += 0.6 * item.intensity.clamp(0.0, 1.0) * 0.5;
    }

    // 0.4 * time-of-day match
    final timeMatch = item.idealTimeBands.contains(timeOfDay) ? 1.0 : 0.0;
    score += 0.4 * timeMatch;

    // -0.5 * recency penalty (played in last 24h)
    if (history?.lastCompleted != null) {
      final hoursAgo = DateTime.now()
          .difference(history!.lastCompleted!)
          .inHours;
      if (hoursAgo < 24) {
        score -= 0.5 * (1.0 - hoursAgo / 24.0);
      }
    }

    // -0.3 staleness: never played gets small boost via inverse
    if (history == null || history.playCount == 0) {
      score += 0.3;
    }

    // 0.2 * variety bonus: prefer tags not recently used
    final overlap = item.tags.where(recentTags.contains).length;
    final varietyScore = overlap == 0 ? 1.0 : 1.0 / (overlap + 1);
    score += 0.2 * varietyScore;

    return score;
  }

  // Least-squares slope on valence values over last 7 moods.
  static double _trendSlope(List<MoodEntry> moods) {
    if (moods.length < 2) return 0.0;
    final n = moods.length;
    double sumX = 0, sumY = 0, sumXY = 0, sumX2 = 0;
    for (int i = 0; i < n; i++) {
      final x = i.toDouble();
      final y = moods[i].valence.toDouble();
      sumX += x;
      sumY += y;
      sumXY += x * y;
      sumX2 += x * x;
    }
    final denom = n * sumX2 - sumX * sumX;
    if (denom == 0) return 0.0;
    return (n * sumXY - sumX * sumY) / denom;
  }

  static Set<String> _recentTags(
    Map<String, CompletionRecord> history,
    List<RecommendableContent> catalog,
  ) {
    final cutoff = DateTime.now().subtract(const Duration(hours: 48));
    final recentIds = history.entries
        .where((e) =>
            e.value.lastCompleted != null &&
            e.value.lastCompleted!.isAfter(cutoff))
        .map((e) => e.key)
        .toSet();

    return catalog
        .where((c) => recentIds.contains(c.id))
        .expand((c) => c.tags)
        .toSet();
  }

  static String _explain({
    required RecommendableContent item,
    required String currentMoodName,
    required double trendSlope,
    required String timeOfDay,
    required CompletionRecord? history,
  }) {
    if (trendSlope < -0.1 && item.intensity < 0.4) {
      return 'Your mood has trended lower this week — this gentle session may help you reset.';
    }
    if (history == null || history.playCount == 0) {
      return 'You haven\'t tried this one yet — it\'s a great fit for when you\'re feeling $currentMoodName.';
    }
    if (item.idealTimeBands.contains(timeOfDay)) {
      return 'This is especially suited for the $timeOfDay and matches your current mood.';
    }
    return 'Recommended based on your current mood and recent activity.';
  }
}
