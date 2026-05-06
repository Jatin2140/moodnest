import '../../data/models/mood_entry.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/date_x.dart';

class InsightResult {
  final String headline;
  final String detail;

  const InsightResult({required this.headline, required this.detail});
}

class InsightEngine {
  static InsightResult generate(List<MoodEntry> moods) {
    if (moods.isEmpty) {
      return const InsightResult(
        headline: 'No data yet',
        detail: 'Log a few moods to see your personal insights.',
      );
    }

    // Time-of-day mood analysis
    final morningMoods =
        moods.where((m) => m.createdAt.hour >= 5 && m.createdAt.hour < 12);
    final eveningMoods =
        moods.where((m) => m.createdAt.hour >= 17 && m.createdAt.hour < 21);

    final morningAvg = _avg(morningMoods.map((m) => m.valence));
    final eveningAvg = _avg(eveningMoods.map((m) => m.valence));

    if (morningAvg != null && eveningAvg != null) {
      if (eveningAvg - morningAvg > 0.5) {
        return InsightResult(
          headline: 'You tend to feel better in the evenings',
          detail:
              'Your evenings average ${eveningAvg.toStringAsFixed(1)}/5 vs mornings at ${morningAvg.toStringAsFixed(1)}/5. A morning breathing session might help start your days stronger.',
        );
      }
      if (morningAvg - eveningAvg > 0.5) {
        return InsightResult(
          headline: 'Mornings are your sweet spot',
          detail:
              'You tend to feel better in the morning (${morningAvg.toStringAsFixed(1)}/5) than evening (${eveningAvg.toStringAsFixed(1)}/5). An evening wind-down session may help.',
        );
      }
    }

    // Weekly trend
    final last7 = moods.take(7).toList();
    final first3 = last7.take(3);
    final last3 = last7.skip(4);
    final firstAvg = _avg(first3.map((m) => m.valence));
    final lastAvg = _avg(last3.map((m) => m.valence));

    if (firstAvg != null && lastAvg != null) {
      if (lastAvg - firstAvg > 0.5) {
        return InsightResult(
          headline: 'Your mood has been improving',
          detail:
              'Compared to earlier this week, you\'ve been feeling noticeably better. Keep up whatever you\'re doing!',
        );
      }
      if (firstAvg - lastAvg > 0.5) {
        return InsightResult(
          headline: 'This week has been a bit tougher',
          detail:
              'Your mood has dipped compared to earlier in the week. Consider a calming session or a moment of journaling tonight.',
        );
      }
    }

    // Most common mood
    final moodCounts = <MoodType, int>{};
    for (final m in moods) {
      moodCounts[m.mood] = (moodCounts[m.mood] ?? 0) + 1;
    }
    final dominant =
        moodCounts.entries.reduce((a, b) => a.value > b.value ? a : b).key;
    final label = MoodPalette.label[dominant]!;

    return InsightResult(
      headline: 'You\'ve felt "$label" most often',
      detail:
          'Over your recent entries, "$label" has been your most logged state. Keep tracking to spot longer-term patterns.',
    );
  }

  static List<double?> moodValencePerDay(List<MoodEntry> moods, int days) {
    final now = DateTime.now();
    return List.generate(days, (i) {
      final day = now.subtract(Duration(days: days - 1 - i));
      final dayMoods = moods
          .where((m) {
            final c = m.createdAt;
            return c.year == day.year && c.month == day.month && c.day == day.day;
          })
          .toList();
      if (dayMoods.isEmpty) return null;
      return dayMoods.map((m) => m.valence.toDouble()).reduce((a, b) => a + b) /
          dayMoods.length;
    });
  }

  static double? _avg(Iterable<int> values) {
    if (values.isEmpty) return null;
    return values.reduce((a, b) => a + b) / values.length;
  }
}
