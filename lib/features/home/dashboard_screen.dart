import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/constants/app_strings.dart';
import '../../core/router/app_router.dart';
import '../../core/utils/date_x.dart';
import '../../providers/auth_provider.dart';
import '../../providers/mood_provider.dart';
import '../../providers/recommendation_provider.dart';
import '../../data/models/meditation.dart';
import '../../data/models/breathing_pattern.dart';
import '../../logic/recommender/mood_recommender.dart';
import '../../widgets/mn_card.dart';
import '../../widgets/mn_section_header.dart';
import '../../widgets/mn_loading.dart';
import '../insights/widgets/calm_garden.dart';
import '../../features/profile/profile_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _refreshRecs());
  }

  void _refreshRecs() {
    final moodP = context.read<MoodProvider>();
    final todayMood = moodP.todayMood;
    if (todayMood == null) return;
    context.read<RecommendationProvider>().refresh(
          currentMood: todayMood.mood,
          last7Moods: moodP.last7,
        );
  }

  String _greeting(String name) {
    final t = DateTime.now().timeLabel;
    final g = switch (t) {
      'morning' => AppStrings.goodMorning,
      'afternoon' => AppStrings.goodAfternoon,
      'evening' => AppStrings.goodEvening,
      _ => AppStrings.goodNight,
    };
    return '$g, $name 👋';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final auth = context.watch<AuthProvider>();
    final name = auth.profile?.displayName ?? 'Friend';

    return Scaffold(
      appBar: AppBar(
        title: Text(AppStrings.appName),
        actions: [
          IconButton(
            icon: const Icon(Icons.flag_outlined),
            tooltip: 'Goals',
            onPressed: () => Navigator.of(context).pushNamed(AppRoutes.goals),
          ),
          IconButton(
            icon: CircleAvatar(
              radius: 16,
              backgroundColor: Theme.of(context)
                  .colorScheme
                  .primary
                  .withOpacity(0.2),
              child: Text(
                name.substring(0, 1).toUpperCase(),
                style: AppTypography.caption.copyWith(
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const ProfileScreen()),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async => _refreshRecs(),
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            // Greeting
            Text(
              _greeting(name),
              style: AppTypography.displayMd.copyWith(
                color:
                    isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
              ),
            ).animate().fadeIn(),
            const SizedBox(height: 4),
            Text(
              AppStrings.howAreYou,
              style: AppTypography.bodyMd.copyWith(
                color: isDark ? AppColors.textMutedDark : AppColors.textMuted,
              ),
            ).animate().fadeIn(delay: 80.ms),
            const SizedBox(height: 20),

            // Today's mood
            _TodayMoodCard(),
            const SizedBox(height: 24),

            // Streak strip
            _StreakStrip(),
            const SizedBox(height: 24),

            // Recommendations
            _RecommendationsSection(),
            const SizedBox(height: 24),

            // Calm Garden teaser
            MnSectionHeader(
              title: AppStrings.calmGarden,
              actionLabel: AppStrings.viewAll,
              onAction: () {
                // switch to insights tab handled by parent nav
              },
            ),
            const SizedBox(height: 12),
            _GardenTeaser(),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}

class _TodayMoodCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final moodP = context.watch<MoodProvider>();
    final today = moodP.todayMood;

    if (today == null) {
      return MnCard(
        onTap: () => Navigator.of(context).pushNamed(AppRoutes.moodCheckIn),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary.withOpacity(0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.add_rounded,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppStrings.logMood,
                    style: AppTypography.titleMd,
                  ),
                  Text(
                    AppStrings.howAreYou,
                    style: AppTypography.bodyMd.copyWith(
                      color: AppColors.textMuted,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded, color: AppColors.textMuted),
          ],
        ),
      ).animate().fadeIn(delay: 120.ms);
    }

    return MnCard(
      mood: today.mood,
      onTap: () => Navigator.of(context).pushNamed(AppRoutes.moodCheckIn),
      child: Row(
        children: [
          Text(
            MoodPalette.emoji[today.mood]!,
            style: const TextStyle(fontSize: 40),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Feeling ${MoodPalette.label[today.mood]!}',
                  style: AppTypography.titleMd,
                ),
                if (today.note != null && today.note!.isNotEmpty)
                  Text(
                    today.note!,
                    style: AppTypography.bodyMd.copyWith(
                      color: AppColors.textMuted,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  )
                else
                  Text(
                    'Tap to add a note',
                    style: AppTypography.bodyMd.copyWith(
                      color: AppColors.textMuted,
                    ),
                  ),
              ],
            ),
          ),
          Icon(Icons.chevron_right_rounded, color: AppColors.textMuted),
        ],
      ),
    ).animate().fadeIn(delay: 120.ms);
  }
}

class _StreakStrip extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final moodP = context.watch<MoodProvider>();
    final dates = moodP.moodDates;
    final last7 = StreakCalculator.last7Days(dates);
    final current = StreakCalculator.currentStreak(dates);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final today = DateTime.now();

    return MnCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                AppStrings.streakTitle,
                style: AppTypography.titleMd,
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('🔥', style: TextStyle(fontSize: 14)),
                    const SizedBox(width: 4),
                    Text(
                      '$current day${current == 1 ? '' : 's'}',
                      style: AppTypography.caption.copyWith(
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(7, (i) {
              final active = last7[i];
              final dayName = ['M', 'T', 'W', 'T', 'F', 'S', 'S'][
                  (today.subtract(Duration(days: 6 - i)).weekday - 1) % 7];
              return Column(
                children: [
                  Text(
                    dayName,
                    style: AppTypography.caption.copyWith(
                      color: isDark ? AppColors.textMutedDark : AppColors.textMuted,
                    ),
                  ),
                  const SizedBox(height: 4),
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: active
                          ? Theme.of(context).colorScheme.primary
                          : (isDark
                              ? AppColors.outlineDark
                              : AppColors.outline),
                    ),
                    child: active
                        ? const Center(
                            child: Text('✓', style: TextStyle(color: Colors.white, fontSize: 14)),
                          )
                        : null,
                  ),
                ],
              );
            }),
          ),
        ],
      ),
    ).animate().fadeIn(delay: 180.ms);
  }
}

class _RecommendationsSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final recP = context.watch<RecommendationProvider>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        MnSectionHeader(title: AppStrings.forYou),
        const SizedBox(height: 12),
        if (recP.isLoading)
          const MnLoading(itemCount: 2)
        else if (recP.recommendations.isEmpty)
          _EmptyRecs()
        else
          SizedBox(
            height: 160,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: recP.recommendations.length,
              separatorBuilder: (_, __) => const SizedBox(width: 12),
              itemBuilder: (context, i) =>
                  _RecCard(rec: recP.recommendations[i]),
            ),
          ),
      ],
    );
  }
}

class _RecCard extends StatefulWidget {
  final Recommendation rec;
  const _RecCard({required this.rec});

  @override
  State<_RecCard> createState() => _RecCardState();
}

class _RecCardState extends State<_RecCard> {
  bool _showWhy = false;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final rec = widget.rec;
    final typeIcon = switch (rec.content.type) {
      ContentType.meditation => Icons.self_improvement_rounded,
      ContentType.breathing => Icons.air_rounded,
      ContentType.journalPrompt => Icons.edit_note_rounded,
    };
    final typeColor = switch (rec.content.type) {
      ContentType.meditation => const Color(0xFF7FB7BE),
      ContentType.breathing => const Color(0xFF8C7BB5),
      ContentType.journalPrompt => const Color(0xFFF5A65B),
    };

    return GestureDetector(
      onTap: () {
        final raw = rec.content.raw;
        if (raw is MeditationModel) {
          Navigator.of(context)
              .pushNamed(AppRoutes.meditationPlayer, arguments: raw);
        } else if (raw is BreathingPattern) {
          Navigator.of(context)
              .pushNamed(AppRoutes.breathingSession, arguments: raw);
        } else {
          Navigator.of(context).pushNamed(
            AppRoutes.journalCompose,
            arguments: (rec.content.raw as Map<String, dynamic>)['id'] as String?,
          );
        }
      },
      child: Container(
        width: 200,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? AppColors.surfaceMutedDark : AppColors.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isDark ? AppColors.outlineDark : AppColors.outline,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: typeColor.withOpacity(0.15),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(typeIcon, size: 18, color: typeColor),
                ),
                const Spacer(),
                GestureDetector(
                  onTap: () => setState(() => _showWhy = !_showWhy),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: typeColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      AppStrings.whyThis,
                      style: AppTypography.caption.copyWith(color: typeColor),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            if (_showWhy)
              Text(
                rec.whyExplanation,
                style: AppTypography.caption.copyWith(
                  color: isDark ? AppColors.textMutedDark : AppColors.textMuted,
                  fontStyle: FontStyle.italic,
                ),
                maxLines: 4,
                overflow: TextOverflow.ellipsis,
              )
            else ...[
              Text(
                rec.content.title,
                style: AppTypography.bodyLg
                    .copyWith(fontWeight: FontWeight.w600),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Expanded(
                child: Text(
                  rec.content.description,
                  style: AppTypography.caption.copyWith(
                    color: isDark ? AppColors.textMutedDark : AppColors.textMuted,
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _EmptyRecs extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.outline),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          const Icon(Icons.mood_rounded, size: 36, color: AppColors.textMuted),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Log your mood first',
                  style: AppTypography.bodyLg
                      .copyWith(fontWeight: FontWeight.w600),
                ),
                Text(
                  'Personalised picks will appear here.',
                  style: AppTypography.bodyMd
                      .copyWith(color: AppColors.textMuted),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _GardenTeaser extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final moodP = context.watch<MoodProvider>();
    return MnCard(
      child: SizedBox(
        height: 120,
        child: CalmGarden(
          moods: moodP.moods,
          isPreview: true,
        ),
      ),
    );
  }
}
