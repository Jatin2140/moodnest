import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_typography.dart';
import 'mn_button.dart';

class MnEmptyState extends StatelessWidget {
  final String title;
  final String body;
  final IconData icon;
  final String? ctaLabel;
  final VoidCallback? onCta;
  final bool isOffline;

  const MnEmptyState({
    super.key,
    required this.title,
    required this.body,
    this.icon = Icons.inbox_outlined,
    this.ctaLabel,
    this.onCta,
    this.isOffline = false,
  });

  const MnEmptyState.offline({
    super.key,
    this.title = 'You\'re offline',
    this.body = 'Data will sync when you reconnect.',
    this.icon = Icons.wifi_off_rounded,
    this.ctaLabel,
    this.onCta,
  }) : isOffline = true;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final iconColor = isOffline
        ? AppColors.textMuted
        : Theme.of(context).colorScheme.primary;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 36, color: iconColor),
            ),
            const SizedBox(height: 20),
            Text(
              title,
              style: AppTypography.titleMd.copyWith(
                color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              body,
              style: AppTypography.bodyMd.copyWith(
                color: isDark ? AppColors.textMutedDark : AppColors.textMuted,
              ),
              textAlign: TextAlign.center,
            ),
            if (ctaLabel != null && onCta != null) ...[
              const SizedBox(height: 24),
              MnButton(
                label: ctaLabel!,
                onPressed: onCta,
                width: 200,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
