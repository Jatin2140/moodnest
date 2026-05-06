import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/mood_gradient.dart';

class MnCard extends StatelessWidget {
  final Widget child;
  final MoodType? mood;
  final EdgeInsets? padding;
  final VoidCallback? onTap;
  final bool useGradient;
  final double borderRadius;

  const MnCard({
    super.key,
    required this.child,
    this.mood,
    this.padding,
    this.onTap,
    this.useGradient = false,
    this.borderRadius = 20,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final gradient = mood != null && useGradient
        ? MoodGradient.forMood(mood!)
        : null;
    final bgColor = mood != null && !useGradient
        ? MoodPalette.softBg[mood]!.withOpacity(isDark ? 0.15 : 1)
        : (isDark ? AppColors.surfaceMutedDark : AppColors.surface);

    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(borderRadius),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(borderRadius),
        child: Ink(
          decoration: BoxDecoration(
            gradient: gradient,
            color: gradient == null ? bgColor : null,
            borderRadius: BorderRadius.circular(borderRadius),
            border: Border.all(
              color: isDark ? AppColors.outlineDark : AppColors.outline,
            ),
          ),
          child: Padding(
            padding: padding ?? const EdgeInsets.all(16),
            child: child,
          ),
        ),
      ),
    );
  }
}
