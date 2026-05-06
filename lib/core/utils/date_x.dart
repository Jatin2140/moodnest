import 'package:intl/intl.dart';

extension DateX on DateTime {
  DateTime get startOfDay => DateTime(year, month, day);
  DateTime get startOfWeek {
    final diff = weekday - 1;
    return subtract(Duration(days: diff)).startOfDay;
  }

  bool isSameDay(DateTime other) =>
      year == other.year && month == other.month && day == other.day;

  bool get isToday => isSameDay(DateTime.now());
  bool get isYesterday => isSameDay(DateTime.now().subtract(const Duration(days: 1)));

  String get friendlyDate {
    if (isToday) return 'Today';
    if (isYesterday) return 'Yesterday';
    return DateFormat('MMM d').format(this);
  }

  String get timeLabel {
    final h = hour;
    if (h >= 5 && h < 12) return 'morning';
    if (h >= 12 && h < 17) return 'afternoon';
    if (h >= 17 && h < 21) return 'evening';
    return 'night';
  }
}

class StreakCalculator {
  static int currentStreak(List<DateTime> dates) {
    if (dates.isEmpty) return 0;
    final days = dates.map((d) => d.startOfDay).toSet().toList()
      ..sort((a, b) => b.compareTo(a));

    final today = DateTime.now().startOfDay;
    final yesterday = today.subtract(const Duration(days: 1));

    // Streak must begin from today or yesterday (haven't logged today yet)
    if (!days.first.isSameDay(today) && !days.first.isSameDay(yesterday)) return 0;

    int streak = 0;
    DateTime expected = days.first;
    for (final date in days) {
      if (date.isSameDay(expected)) {
        streak++;
        expected = expected.subtract(const Duration(days: 1));
      } else {
        break;
      }
    }
    return streak;
  }

  static int longestStreak(List<DateTime> dates) {
    if (dates.isEmpty) return 0;
    final sorted = dates.map((d) => d.startOfDay).toSet().toList()
      ..sort();

    int longest = 1;
    int current = 1;

    for (int i = 1; i < sorted.length; i++) {
      final diff = sorted[i].difference(sorted[i - 1]).inDays;
      if (diff == 1) {
        current++;
        if (current > longest) longest = current;
      } else if (diff > 1) {
        current = 1;
      }
    }
    return longest;
  }

  static List<bool> last7Days(List<DateTime> dates) {
    final today = DateTime.now().startOfDay;
    return List.generate(7, (i) {
      final day = today.subtract(Duration(days: 6 - i));
      return dates.any((d) => d.startOfDay.isSameDay(day));
    });
  }
}
