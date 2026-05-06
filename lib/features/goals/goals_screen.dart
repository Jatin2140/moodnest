import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/constants/app_strings.dart';
import '../../core/router/app_router.dart';
import '../../data/models/goal.dart';
import '../../providers/goal_provider.dart';
import '../../widgets/mn_empty_state.dart';
import '../../widgets/mn_card.dart';

class GoalsScreen extends StatefulWidget {
  const GoalsScreen({super.key});

  @override
  State<GoalsScreen> createState() => _GoalsScreenState();
}

class _GoalsScreenState extends State<GoalsScreen> {
  bool _showCelebration = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final goalP = context.read<GoalProvider>();
    if (goalP.justCompletedGoalId != null && !_showCelebration) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        setState(() => _showCelebration = true);
        Future.delayed(const Duration(seconds: 3), () {
          if (mounted) {
            setState(() => _showCelebration = false);
            goalP.clearJustCompleted();
          }
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final goalP = context.watch<GoalProvider>();
    final active = goalP.activeGoals;

    return Stack(
      children: [
        Scaffold(
          appBar: AppBar(
            title: Text(AppStrings.goalsTitle),
            actions: [
              if (active.length < 5)
                IconButton(
                  icon: const Icon(Icons.add_rounded),
                  onPressed: () =>
                      Navigator.of(context).pushNamed(AppRoutes.goalForm),
                ),
            ],
          ),
          body: goalP.isLoading
              ? const Center(child: CircularProgressIndicator(strokeWidth: 2))
              : active.isEmpty
                  ? MnEmptyState(
                      title: AppStrings.noGoals,
                      body: AppStrings.noGoalsSub,
                      icon: Icons.flag_outlined,
                      ctaLabel: AppStrings.newGoal,
                      onCta: () =>
                          Navigator.of(context).pushNamed(AppRoutes.goalForm),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(20),
                      itemCount: active.length + 1,
                      itemBuilder: (context, i) {
                        if (i == 0) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 16),
                            child: Text(
                              AppStrings.goalsSub,
                              style: AppTypography.bodyMd.copyWith(
                                color: AppColors.textMuted,
                              ),
                            ),
                          );
                        }
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 14),
                          child: _GoalCard(goal: active[i - 1]),
                        );
                      },
                    ),
        ),
        if (_showCelebration)
          Positioned.fill(
            child: IgnorePointer(
              child: Container(
                color: Colors.black.withOpacity(0.3),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Fallback if no Lottie asset
                    const Text('🎉', style: TextStyle(fontSize: 80)),
                    const SizedBox(height: 16),
                    Text(
                      'Goal reached!',
                      style: AppTypography.displayMd.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    Text(
                      'A new flower is blooming in your garden.',
                      style: AppTypography.bodyLg.copyWith(
                        color: Colors.white.withOpacity(0.9),
                      ),
                    ),
                  ],
                ),
              ),
            ).animate().fadeIn(duration: 400.ms),
          ),
      ],
    );
  }
}

class _GoalCard extends StatelessWidget {
  final Goal goal;
  const _GoalCard({required this.goal});

  @override
  Widget build(BuildContext context) {
    final goalP = context.read<GoalProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final progress =
        (goal.currentWeekProgress / goal.targetPerWeek).clamp(0.0, 1.0);
    final accent = _categoryColor(goal.category);
    final emoji = _categoryEmoji(goal.category);

    return MnCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(emoji, style: const TextStyle(fontSize: 24)),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(goal.title,
                        style: AppTypography.bodyLg
                            .copyWith(fontWeight: FontWeight.w600)),
                    Text(
                      '${goal.currentWeekProgress} / ${goal.targetPerWeek}× this week',
                      style: AppTypography.caption.copyWith(
                        color: isDark ? AppColors.textMutedDark : AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
              if (goal.isCompleted)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.success.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '✓ Done',
                    style: AppTypography.caption.copyWith(
                      color: AppColors.success,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                )
              else
                PopupMenuButton<String>(
                  icon: Icon(Icons.more_vert_rounded,
                      size: 20, color: AppColors.textMuted),
                  itemBuilder: (_) => [
                    const PopupMenuItem(value: 'archive', child: Text('Remove')),
                  ],
                  onSelected: (v) {
                    if (v == 'archive') goalP.archiveGoal(goal.id);
                  },
                ),
            ],
          ),
          const SizedBox(height: 14),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              backgroundColor:
                  isDark ? AppColors.outlineDark : AppColors.outline,
              valueColor: AlwaysStoppedAnimation<Color>(accent),
            ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: 60.ms);
  }

  Color _categoryColor(GoalCategory c) => switch (c) {
        GoalCategory.meditate => const Color(0xFF7FB7BE),
        GoalCategory.breathe => const Color(0xFF8C7BB5),
        GoalCategory.journal => const Color(0xFFF5A65B),
        GoalCategory.moodlog => const Color(0xFFD17A88),
      };

  String _categoryEmoji(GoalCategory c) => switch (c) {
        GoalCategory.meditate => '🧘',
        GoalCategory.breathe => '💨',
        GoalCategory.journal => '📖',
        GoalCategory.moodlog => '😊',
      };
}
