import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/constants/app_strings.dart';
import '../../data/models/goal.dart';
import '../../providers/goal_provider.dart';
import '../../widgets/mn_button.dart';

class GoalFormScreen extends StatefulWidget {
  const GoalFormScreen({super.key});

  @override
  State<GoalFormScreen> createState() => _GoalFormScreenState();
}

class _GoalFormScreenState extends State<GoalFormScreen> {
  final _titleCtrl = TextEditingController();
  GoalCategory _category = GoalCategory.meditate;
  int _target = 3;
  bool _saving = false;

  @override
  void dispose() {
    _titleCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final title = _titleCtrl.text.trim();
    if (title.isEmpty) return;
    setState(() => _saving = true);
    final goalP = context.read<GoalProvider>();
    await goalP.addGoal(
      title: title,
      category: _category,
      targetPerWeek: _target,
    );
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(AppStrings.newGoal),
        leading: IconButton(
          icon: const Icon(Icons.close_rounded),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Goal name', style: AppTypography.caption.copyWith(
                color: isDark ? AppColors.textMutedDark : AppColors.textMuted,
                fontWeight: FontWeight.w600,
              )),
              const SizedBox(height: 8),
              TextField(
                controller: _titleCtrl,
                autofocus: true,
                decoration: const InputDecoration(
                  hintText: 'e.g. Meditate before bed',
                ),
                style: AppTypography.bodyLg,
              ),
              const SizedBox(height: 28),
              Text('Category', style: AppTypography.caption.copyWith(
                color: isDark ? AppColors.textMutedDark : AppColors.textMuted,
                fontWeight: FontWeight.w600,
              )),
              const SizedBox(height: 10),
              Wrap(
                spacing: 10,
                children: GoalCategory.values.map((c) {
                  final active = _category == c;
                  final color = _catColor(c);
                  return ChoiceChip(
                    label: Text('${_catEmoji(c)} ${_catLabel(c)}'),
                    selected: active,
                    selectedColor: color.withOpacity(0.2),
                    onSelected: (_) => setState(() => _category = c),
                    labelStyle: AppTypography.caption.copyWith(
                      color: active ? color : (isDark ? AppColors.textMutedDark : AppColors.textMuted),
                      fontWeight: active ? FontWeight.w700 : FontWeight.w400,
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 28),
              Text('Sessions per week', style: AppTypography.caption.copyWith(
                color: isDark ? AppColors.textMutedDark : AppColors.textMuted,
                fontWeight: FontWeight.w600,
              )),
              const SizedBox(height: 10),
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.remove_circle_outline_rounded),
                    onPressed: _target > 1 ? () => setState(() => _target--) : null,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  Text(
                    '$_target×',
                    style: AppTypography.displayMd.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.add_circle_outline_rounded),
                    onPressed: _target < 7 ? () => setState(() => _target++) : null,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'per week',
                    style: AppTypography.bodyMd.copyWith(
                      color: isDark ? AppColors.textMutedDark : AppColors.textMuted,
                    ),
                  ),
                ],
              ),
              const Spacer(),
              MnButton(
                label: 'Save goal',
                onPressed: _titleCtrl.text.trim().isNotEmpty && !_saving
                    ? _save
                    : null,
                isLoading: _saving,
                width: double.infinity,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _catColor(GoalCategory c) => switch (c) {
        GoalCategory.meditate => const Color(0xFF7FB7BE),
        GoalCategory.breathe => const Color(0xFF8C7BB5),
        GoalCategory.journal => const Color(0xFFF5A65B),
        GoalCategory.moodlog => const Color(0xFFD17A88),
      };

  String _catEmoji(GoalCategory c) => switch (c) {
        GoalCategory.meditate => '🧘',
        GoalCategory.breathe => '💨',
        GoalCategory.journal => '📖',
        GoalCategory.moodlog => '😊',
      };

  String _catLabel(GoalCategory c) => switch (c) {
        GoalCategory.meditate => 'Meditate',
        GoalCategory.breathe => 'Breathe',
        GoalCategory.journal => 'Journal',
        GoalCategory.moodlog => 'Mood log',
      };
}
