import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';

class PromptCard extends StatelessWidget {
  final String text;
  final bool selected;
  final VoidCallback onTap;

  const PromptCard({
    super.key,
    required this.text,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    const accent = Color(0xFFF5A65B);

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: selected
              ? accent.withOpacity(0.12)
              : (isDark ? AppColors.surfaceMutedDark : AppColors.surface),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selected ? accent : (isDark ? AppColors.outlineDark : AppColors.outline),
            width: selected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                text,
                style: AppTypography.bodyMd.copyWith(
                  color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
            if (selected)
              const Icon(Icons.check_circle_rounded, color: accent, size: 20),
          ],
        ),
      ),
    );
  }
}
