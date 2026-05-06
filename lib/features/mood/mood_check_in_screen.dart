import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/constants/app_strings.dart';
import '../../data/models/goal.dart';
import '../../providers/mood_provider.dart';
import '../../providers/goal_provider.dart';
import '../../providers/recommendation_provider.dart';
import '../../widgets/mn_button.dart';
import 'widgets/mood_picker.dart';

class MoodCheckInScreen extends StatefulWidget {
  const MoodCheckInScreen({super.key});

  @override
  State<MoodCheckInScreen> createState() => _MoodCheckInScreenState();
}

class _MoodCheckInScreenState extends State<MoodCheckInScreen> {
  MoodType? _selected;
  final _noteCtrl = TextEditingController();
  final Set<String> _tags = {};
  bool _saving = false;

  static const _predefinedTags = [
    'work', 'sleep', 'social', 'health', 'family', 'exercise',
  ];

  @override
  void dispose() {
    _noteCtrl.dispose();
    super.dispose();
  }

  Future<void> _save(BuildContext context) async {
    if (_selected == null) return;
    setState(() => _saving = true);

    final moodP = context.read<MoodProvider>();
    final goalP = context.read<GoalProvider>();
    final recP = context.read<RecommendationProvider>();

    await moodP.logMood(
      mood: _selected!,
      note: _noteCtrl.text.trim().isEmpty ? null : _noteCtrl.text.trim(),
      tags: _tags.toList(),
    );

    await goalP.recordProgress(GoalCategory.moodlog);

    // Refresh recommendations based on new mood
    await recP.refresh(
      currentMood: _selected!,
      last7Moods: moodP.last7,
    );

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppStrings.moodSaved),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          duration: const Duration(seconds: 2),
        ),
      );
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final accent = _selected != null
        ? MoodPalette.primary[_selected]!
        : Theme.of(context).colorScheme.primary;

    return Scaffold(
      appBar: AppBar(
        title: Text(AppStrings.moodCheckIn),
        leading: IconButton(
          icon: const Icon(Icons.close_rounded),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Right now I feel...',
                style: AppTypography.titleLg.copyWith(
                  color: isDark
                      ? AppColors.textPrimaryDark
                      : AppColors.textPrimary,
                ),
              ).animate().fadeIn(),
              const SizedBox(height: 28),
              MoodPicker(
                selected: _selected,
                onSelect: (m) => setState(() => _selected = m),
              ).animate().fadeIn(delay: 100.ms),
              if (_selected != null) ...[
                const SizedBox(height: 12),
                Center(
                  child: Text(
                    MoodPalette.label[_selected]!,
                    style: AppTypography.titleMd.copyWith(
                      color: accent,
                      fontWeight: FontWeight.w700,
                    ),
                  ).animate().fadeIn(),
                ),
              ],
              const SizedBox(height: 32),
              Text(
                AppStrings.addNote,
                style: AppTypography.caption.copyWith(
                  color:
                      isDark ? AppColors.textMutedDark : AppColors.textMuted,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _noteCtrl,
                maxLength: 280,
                maxLines: 3,
                style: AppTypography.bodyMd.copyWith(
                  color: isDark
                      ? AppColors.textPrimaryDark
                      : AppColors.textPrimary,
                ),
                decoration: InputDecoration(
                  hintText: 'What\'s on your mind?',
                  counterText: '',
                ),
              ).animate().fadeIn(delay: 150.ms),
              const SizedBox(height: 24),
              Text(
                AppStrings.addTags,
                style: AppTypography.caption.copyWith(
                  color:
                      isDark ? AppColors.textMutedDark : AppColors.textMuted,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _predefinedTags.map((tag) {
                  final active = _tags.contains(tag);
                  return FilterChip(
                    label: Text(tag),
                    selected: active,
                    onSelected: (v) => setState(() {
                      if (v) {
                        _tags.add(tag);
                      } else {
                        _tags.remove(tag);
                      }
                    }),
                    selectedColor:
                        (accent).withOpacity(0.2),
                    checkmarkColor: accent,
                  );
                }).toList(),
              ).animate().fadeIn(delay: 200.ms),
              const SizedBox(height: 36),
              MnButton(
                label: AppStrings.saveMood,
                onPressed: _selected != null && !_saving
                    ? () => _save(context)
                    : null,
                isLoading: _saving,
                width: double.infinity,
                accentMood: _selected,
              ).animate().fadeIn(delay: 250.ms),
            ],
          ),
        ),
      ),
    );
  }
}
