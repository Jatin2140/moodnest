import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/constants/app_strings.dart';
import '../../core/router/app_router.dart';
import '../../data/models/meditation.dart';
import '../../data/repositories/content_repository.dart';
import '../../widgets/mn_empty_state.dart';
import '../../widgets/mn_loading.dart';
import '../../widgets/mn_card.dart';

class MeditationListScreen extends StatefulWidget {
  const MeditationListScreen({super.key});

  @override
  State<MeditationListScreen> createState() => _MeditationListScreenState();
}

class _MeditationListScreenState extends State<MeditationListScreen> {
  List<MeditationModel> _meditations = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final items = await ContentRepository().getMeditations();
    if (mounted) setState(() {
      _meditations = items;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final grouped = <String, List<MeditationModel>>{};
    for (final m in _meditations) {
      grouped.putIfAbsent(m.category, () => []).add(m);
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(AppStrings.meditationTitle),
        automaticallyImplyLeading: false,
      ),
      body: _loading
          ? const Padding(
              padding: EdgeInsets.all(20),
              child: MnLoading(),
            )
          : _meditations.isEmpty
              ? const MnEmptyState(
                  title: 'No sessions yet',
                  body: 'Sessions will appear here once loaded.',
                  icon: Icons.self_improvement_rounded,
                )
              : ListView(
                  padding: const EdgeInsets.all(20),
                  children: [
                    Text(
                      AppStrings.meditationSub,
                      style: AppTypography.bodyMd.copyWith(
                        color: isDark
                            ? AppColors.textMutedDark
                            : AppColors.textMuted,
                      ),
                    ).animate().fadeIn(),
                    const SizedBox(height: 20),
                    ...grouped.entries.map((entry) {
                      final label = _categoryLabel(entry.key);
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(label, style: AppTypography.titleMd)
                              .animate().fadeIn(),
                          const SizedBox(height: 12),
                          ...entry.value.map((m) => Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: _MeditationTile(meditation: m),
                              )),
                          const SizedBox(height: 12),
                        ],
                      );
                    }),
                  ],
                ),
    );
  }

  String _categoryLabel(String cat) => switch (cat) {
        'sleep' => '😴 Sleep',
        'focus' => '🎯 Focus',
        'reset' => '🔄 Reset',
        'body_scan' => '🧘 Body Scan',
        _ => cat,
      };
}

class _MeditationTile extends StatelessWidget {
  final MeditationModel meditation;
  const _MeditationTile({required this.meditation});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return MnCard(
      onTap: () => Navigator.of(context)
          .pushNamed(AppRoutes.meditationPlayer, arguments: meditation),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: const Color(0xFF7FB7BE).withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.self_improvement_rounded,
              color: Color(0xFF7FB7BE),
              size: 26,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(meditation.title, style: AppTypography.bodyLg.copyWith(fontWeight: FontWeight.w600)),
                const SizedBox(height: 2),
                Text(
                  meditation.description,
                  style: AppTypography.bodyMd.copyWith(
                    color: isDark ? AppColors.textMutedDark : AppColors.textMuted,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                meditation.durationLabel,
                style: AppTypography.caption.copyWith(
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Icon(Icons.play_circle_rounded,
                  color: Theme.of(context).colorScheme.primary, size: 28),
            ],
          ),
        ],
      ),
    );
  }
}
