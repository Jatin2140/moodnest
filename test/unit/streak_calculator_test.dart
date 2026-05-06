import 'package:flutter_test/flutter_test.dart';
import 'package:moodnest/core/utils/date_x.dart';

void main() {
  DateTime day(int daysAgo) =>
      DateTime.now().subtract(Duration(days: daysAgo));

  group('StreakCalculator.currentStreak', () {
    test('returns 0 for empty list', () {
      expect(StreakCalculator.currentStreak([]), 0);
    });

    test('returns 1 for only today', () {
      expect(StreakCalculator.currentStreak([day(0)]), 1);
    });

    test('counts consecutive days including today', () {
      expect(
        StreakCalculator.currentStreak([day(0), day(1), day(2)]),
        3,
      );
    });

    test('stops at gap', () {
      // today + 2 days ago (gap on day 1)
      expect(StreakCalculator.currentStreak([day(0), day(2)]), 1);
    });

    test('handles duplicates on same day (deduplicates)', () {
      expect(
        StreakCalculator.currentStreak([day(0), day(0), day(1)]),
        2,
      );
    });
  });

  group('StreakCalculator.longestStreak', () {
    test('returns 0 for empty list', () {
      expect(StreakCalculator.longestStreak([]), 0);
    });

    test('returns 1 for single entry', () {
      expect(StreakCalculator.longestStreak([day(5)]), 1);
    });

    test('finds longest run across a gap', () {
      // 5 consecutive, gap, 2 consecutive
      final dates = [
        day(10), day(9), day(8), day(7), day(6), // streak of 5
        day(3), day(2),                            // streak of 2
      ];
      expect(StreakCalculator.longestStreak(dates), 5);
    });
  });

  group('StreakCalculator.last7Days', () {
    test('marks today as true', () {
      final result = StreakCalculator.last7Days([day(0)]);
      expect(result.last, isTrue);
    });

    test('returns all false when no moods', () {
      final result = StreakCalculator.last7Days([]);
      expect(result.every((b) => !b), isTrue);
    });

    test('length is always 7', () {
      expect(StreakCalculator.last7Days([day(0), day(3)]).length, 7);
    });
  });
}
