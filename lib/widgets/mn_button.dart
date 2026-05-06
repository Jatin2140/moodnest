import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_typography.dart';

enum MnButtonVariant { primary, secondary, ghost }

class MnButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final MnButtonVariant variant;
  final bool isLoading;
  final IconData? icon;
  final MoodType? accentMood;
  final double? width;

  const MnButton({
    super.key,
    required this.label,
    this.onPressed,
    this.variant = MnButtonVariant.primary,
    this.isLoading = false,
    this.icon,
    this.accentMood,
    this.width,
  });

  @override
  Widget build(BuildContext context) {
    final accent = accentMood != null
        ? MoodPalette.primary[accentMood]!
        : Theme.of(context).colorScheme.primary;

    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SizedBox(
      width: width,
      height: 52,
      child: switch (variant) {
        MnButtonVariant.primary => _PrimaryButton(
            label: label,
            onPressed: isLoading ? null : onPressed,
            isLoading: isLoading,
            icon: icon,
            accent: accent,
          ),
        MnButtonVariant.secondary => _SecondaryButton(
            label: label,
            onPressed: isLoading ? null : onPressed,
            isLoading: isLoading,
            icon: icon,
            accent: accent,
            isDark: isDark,
          ),
        MnButtonVariant.ghost => _GhostButton(
            label: label,
            onPressed: isLoading ? null : onPressed,
            isLoading: isLoading,
            icon: icon,
            accent: accent,
          ),
      },
    );
  }
}

class _PrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final IconData? icon;
  final Color accent;

  const _PrimaryButton({
    required this.label,
    this.onPressed,
    required this.isLoading,
    this.icon,
    required this.accent,
  });

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [accent, accent.withOpacity(0.8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: accent.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: _ButtonContent(
              label: label,
              isLoading: isLoading,
              icon: icon,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}

class _SecondaryButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final IconData? icon;
  final Color accent;
  final bool isDark;

  const _SecondaryButton({
    required this.label,
    this.onPressed,
    required this.isLoading,
    this.icon,
    required this.accent,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: isDark ? AppColors.surfaceMutedDark : AppColors.surfaceMuted,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isDark ? AppColors.outlineDark : AppColors.outline,
            ),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: _ButtonContent(
            label: label,
            isLoading: isLoading,
            icon: icon,
            color: accent,
          ),
        ),
      ),
    );
  }
}

class _GhostButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final IconData? icon;
  final Color accent;

  const _GhostButton({
    required this.label,
    this.onPressed,
    required this.isLoading,
    this.icon,
    required this.accent,
  });

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        foregroundColor: accent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        padding: const EdgeInsets.symmetric(horizontal: 24),
      ),
      child: _ButtonContent(
        label: label,
        isLoading: isLoading,
        icon: icon,
        color: accent,
      ),
    );
  }
}

class _ButtonContent extends StatelessWidget {
  final String label;
  final bool isLoading;
  final IconData? icon;
  final Color color;

  const _ButtonContent({
    required this.label,
    required this.isLoading,
    this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Center(
        child: SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: color,
          ),
        ),
      );
    }
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (icon != null) ...[
          Icon(icon, size: 18, color: color),
          const SizedBox(width: 8),
        ],
        Text(label, style: AppTypography.button.copyWith(color: color)),
      ],
    );
  }
}
