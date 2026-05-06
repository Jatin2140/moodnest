import 'package:flutter/material.dart';
import 'app_colors.dart';

class MoodGradient {
  MoodGradient._();

  static LinearGradient forMood(MoodType mood) {
    final primary = MoodPalette.primary[mood]!;
    final soft = MoodPalette.softBg[mood]!;
    return LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [soft, primary.withOpacity(0.3)],
    );
  }

  static LinearGradient get brand => const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: AppColors.brandGradient,
      );

  static LinearGradient get softPeach => LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          const Color(0xFFFFF1E0),
          const Color(0xFFF5A65B).withOpacity(0.1),
        ],
      );
}
