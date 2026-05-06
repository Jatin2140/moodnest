import 'package:flutter/material.dart';

enum MoodType { joyful, calm, neutral, low, stressed }

class MoodPalette {
  MoodPalette._();

  static const Map<MoodType, Color> primary = {
    MoodType.joyful: Color(0xFFF5A65B),
    MoodType.calm: Color(0xFF7FB7BE),
    MoodType.neutral: Color(0xFFB7B5C9),
    MoodType.low: Color(0xFF8C7BB5),
    MoodType.stressed: Color(0xFFD17A88),
  };

  static const Map<MoodType, Color> softBg = {
    MoodType.joyful: Color(0xFFFFF1E0),
    MoodType.calm: Color(0xFFE5F1F2),
    MoodType.neutral: Color(0xFFF1F0F7),
    MoodType.low: Color(0xFFEDE7F6),
    MoodType.stressed: Color(0xFFFBE6EA),
  };

  static const Map<MoodType, String> emoji = {
    MoodType.joyful: '😊',
    MoodType.calm: '😌',
    MoodType.neutral: '😐',
    MoodType.low: '😔',
    MoodType.stressed: '😰',
  };

  static const Map<MoodType, String> label = {
    MoodType.joyful: 'Joyful',
    MoodType.calm: 'Calm',
    MoodType.neutral: 'Neutral',
    MoodType.low: 'Low',
    MoodType.stressed: 'Stressed',
  };

  static const Map<MoodType, int> valence = {
    MoodType.joyful: 5,
    MoodType.calm: 4,
    MoodType.neutral: 3,
    MoodType.low: 2,
    MoodType.stressed: 1,
  };

  static MoodType fromValence(int v) {
    return valence.entries
        .firstWhere((e) => e.value == v.clamp(1, 5),
            orElse: () => const MapEntry(MoodType.neutral, 3))
        .key;
  }
}

class AppColors {
  AppColors._();

  // Surfaces
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceMuted = Color(0xFFF8F7FC);
  static const Color surfaceDark = Color(0xFF1A1825);
  static const Color surfaceMutedDark = Color(0xFF252235);

  // Text
  static const Color textPrimary = Color(0xFF1A1825);
  static const Color textMuted = Color(0xFF7A7A8C);
  static const Color textPrimaryDark = Color(0xFFF5F4FF);
  static const Color textMutedDark = Color(0xFFAAA8BF);

  // Semantic
  static const Color success = Color(0xFF4CAF82);
  static const Color warning = Color(0xFFF5A65B);
  static const Color danger = Color(0xFFD17A88);
  static const Color outline = Color(0xFFE8E6F0);
  static const Color outlineDark = Color(0xFF3A3650);

  // Brand gradient
  static const List<Color> brandGradient = [
    Color(0xFFF5A65B),
    Color(0xFFD17A88),
    Color(0xFF8C7BB5),
  ];
}
