import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/constants/app_strings.dart';
import '../../core/router/app_router.dart';
import '../../data/models/breathing_pattern.dart';
import '../../data/repositories/content_repository.dart';
import '../../widgets/mn_loading.dart';
import '../../widgets/mn_card.dart';

class BreathingListScreen extends StatefulWidget {
  const BreathingListScreen({super.key});

  @override
  State<BreathingListScreen> createState() => _BreathingListScreenState();
}

class _BreathingListScreenState extends State<BreathingListScreen> {
  List<BreathingPattern> _patterns = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    ContentRepository().getBreathingPatterns().then((p) {
      if (mounted) setState(() { _patterns = p; _loading = false; });
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      appBar: AppBar(
        title: Text(AppStrings.breathingTitle),
        automaticallyImplyLeading: false,
      ),
      body: _loading
          ? const Padding(padding: EdgeInsets.all(20), child: MnLoading())
          : ListView.builder(
              padding: const EdgeInsets.all(20),
              itemCount: _patterns.length + 1,
              itemBuilder: (context, i) {
                if (i == 0) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 20),
                    child: Text(
                      AppStrings.breathingSub,
                      style: AppTypography.bodyMd.copyWith(
                        color: isDark ? AppColors.textMutedDark : AppColors.textMuted,
                      ),
                    ).animate().fadeIn(),
                  );
                }
                final p = _patterns[i - 1];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 14),
                  child: _PatternCard(pattern: p),
                );
              },
            ),
    );
  }
}

class _PatternCard extends StatelessWidget {
  final BreathingPattern pattern;
  const _PatternCard({required this.pattern});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    const accent = Color(0xFF8C7BB5);

    return MnCard(
      onTap: () => Navigator.of(context)
          .pushNamed(AppRoutes.breathingSession, arguments: pattern),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: accent.withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.air_rounded, color: accent, size: 24),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(pattern.name,
                        style: AppTypography.bodyLg.copyWith(fontWeight: FontWeight.w600)),
                    Text(
                      pattern.patternLabel,
                      style: AppTypography.caption.copyWith(
                        color: accent,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 1,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: accent.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '${pattern.recommendedCycles}×',
                  style: AppTypography.caption.copyWith(
                    color: accent,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            pattern.description,
            style: AppTypography.bodyMd.copyWith(
              color: isDark ? AppColors.textMutedDark : AppColors.textMuted,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 6,
            children: pattern.tags.take(3).map((t) => Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: accent.withOpacity(0.08),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(t, style: AppTypography.caption.copyWith(color: accent)),
            )).toList(),
          ),
        ],
      ),
    ).animate().fadeIn(delay: Duration(milliseconds: 80));
  }
}
