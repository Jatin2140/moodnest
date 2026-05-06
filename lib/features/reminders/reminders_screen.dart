import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/constants/app_strings.dart';
import '../../data/models/reminder.dart';
import '../../providers/reminder_provider.dart';
import '../../widgets/mn_empty_state.dart';
import '../../widgets/mn_card.dart';
import '../../widgets/mn_button.dart';
import '../../main.dart';

class RemindersScreen extends StatelessWidget {
  const RemindersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final remP = context.watch<ReminderProvider>();

    return Scaffold(
      appBar: AppBar(
        title: Text(AppStrings.remindersTitle),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: remP.isLoading
          ? const Center(child: CircularProgressIndicator(strokeWidth: 2))
          : remP.reminders.isEmpty
              ? MnEmptyState(
                  title: AppStrings.noReminders,
                  body: AppStrings.noRemindersSub,
                  icon: Icons.notifications_outlined,
                  ctaLabel: AppStrings.newReminder,
                  onCta: () => _showAddSheet(context),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(20),
                  itemCount: remP.reminders.length + 1,
                  itemBuilder: (context, i) {
                    if (i == 0) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: MnButton(
                          label: AppStrings.newReminder,
                          variant: MnButtonVariant.secondary,
                          onPressed: () => _showAddSheet(context),
                          icon: Icons.add_rounded,
                        ),
                      );
                    }
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _ReminderTile(reminder: remP.reminders[i - 1]),
                    );
                  },
                ),
      floatingActionButton: remP.reminders.isNotEmpty
          ? FloatingActionButton(
              onPressed: () => _showAddSheet(context),
              backgroundColor: Theme.of(context).colorScheme.primary,
              child: const Icon(Icons.add_rounded, color: Colors.white),
            )
          : null,
    );
  }

  void _showAddSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => ChangeNotifierProvider.value(
        value: context.read<ReminderProvider>(),
        child: const _AddReminderSheet(),
      ),
    );
  }
}

class _ReminderTile extends StatelessWidget {
  final Reminder reminder;
  const _ReminderTile({required this.reminder});

  @override
  Widget build(BuildContext context) {
    final remP = context.read<ReminderProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    const dayLabels = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];

    return MnCard(
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(reminder.label, style: AppTypography.bodyLg.copyWith(fontWeight: FontWeight.w600)),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      reminder.time,
                      style: AppTypography.bodyMd.copyWith(
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 10),
                    ...List.generate(7, (i) {
                      final day = i + 1;
                      final active = reminder.daysOfWeek.contains(day);
                      return Container(
                        margin: const EdgeInsets.only(right: 4),
                        width: 20,
                        height: 20,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: active
                              ? Theme.of(context).colorScheme.primary.withOpacity(0.2)
                              : Colors.transparent,
                        ),
                        child: Center(
                          child: Text(
                            dayLabels[i],
                            style: AppTypography.caption.copyWith(
                              fontSize: 9,
                              fontWeight: FontWeight.w700,
                              color: active
                                  ? Theme.of(context).colorScheme.primary
                                  : (isDark ? AppColors.textMutedDark : AppColors.textMuted),
                            ),
                          ),
                        ),
                      );
                    }),
                  ],
                ),
              ],
            ),
          ),
          Column(
            children: [
              Switch(
                value: reminder.enabled,
                onChanged: (_) => remP.toggleReminder(reminder.id),
                activeColor: Theme.of(context).colorScheme.primary,
              ),
              GestureDetector(
                onTap: () => remP.deleteReminder(reminder.id),
                child: const Icon(Icons.delete_outline_rounded,
                    size: 18, color: AppColors.danger),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _AddReminderSheet extends StatefulWidget {
  const _AddReminderSheet();

  @override
  State<_AddReminderSheet> createState() => _AddReminderSheetState();
}

class _AddReminderSheetState extends State<_AddReminderSheet> {
  ReminderType _type = ReminderType.mood;
  TimeOfDay _time = const TimeOfDay(hour: 9, minute: 0);
  final Set<int> _days = {1, 2, 3, 4, 5};
  bool _saving = false;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final remP = context.read<ReminderProvider>();
    const dayLabels = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

    return Padding(
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(AppStrings.newReminder, style: AppTypography.titleLg),
          const SizedBox(height: 20),
          Text('Type', style: AppTypography.caption.copyWith(
            color: isDark ? AppColors.textMutedDark : AppColors.textMuted,
            fontWeight: FontWeight.w600,
          )),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: ReminderType.values.map((t) => ChoiceChip(
              label: Text(_typeLabel(t)),
              selected: _type == t,
              onSelected: (_) => setState(() => _type = t),
            )).toList(),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Time', style: AppTypography.caption.copyWith(
                      color: isDark ? AppColors.textMutedDark : AppColors.textMuted,
                      fontWeight: FontWeight.w600,
                    )),
                    const SizedBox(height: 8),
                    GestureDetector(
                      onTap: () async {
                        final picked = await showTimePicker(
                          context: context,
                          initialTime: _time,
                        );
                        if (picked != null) setState(() => _time = picked);
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          color: isDark ? AppColors.surfaceMutedDark : AppColors.surfaceMuted,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: isDark ? AppColors.outlineDark : AppColors.outline),
                        ),
                        child: Text(
                          _time.format(context),
                          style: AppTypography.titleMd.copyWith(
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Text('Days', style: AppTypography.caption.copyWith(
            color: isDark ? AppColors.textMutedDark : AppColors.textMuted,
            fontWeight: FontWeight.w600,
          )),
          const SizedBox(height: 8),
          Wrap(
            spacing: 6,
            children: List.generate(7, (i) {
              final day = i + 1;
              final active = _days.contains(day);
              return GestureDetector(
                onTap: () => setState(() {
                  if (active) { _days.remove(day); } else { _days.add(day); }
                }),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: active
                        ? Theme.of(context).colorScheme.primary
                        : (isDark ? AppColors.outlineDark : AppColors.outline),
                  ),
                  child: Center(
                    child: Text(
                      dayLabels[i].substring(0, 2),
                      style: AppTypography.caption.copyWith(
                        color: active ? Colors.white : (isDark ? AppColors.textMutedDark : AppColors.textMuted),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: 24),
          MnButton(
            label: 'Save reminder',
            isLoading: _saving,
            onPressed: _days.isEmpty || _saving
                ? null
                : () async {
                    // Request permission on first reminder
                    await notificationsPlugin
                        .resolvePlatformSpecificImplementation<
                            AndroidFlutterLocalNotificationsPlugin>()
                        ?.requestNotificationsPermission();
                    setState(() => _saving = true);
                    final hh = _time.hour.toString().padLeft(2, '0');
                    final mm = _time.minute.toString().padLeft(2, '0');
                    await remP.addReminder(
                      type: _type,
                      time: '$hh:$mm',
                      daysOfWeek: _days.toList()..sort(),
                    );
                    if (mounted) Navigator.of(context).pop();
                  },
            width: double.infinity,
          ),
        ],
      ),
    );
  }

  String _typeLabel(ReminderType t) => switch (t) {
        ReminderType.mood => '😊 Mood',
        ReminderType.meditate => '🧘 Meditate',
        ReminderType.journal => '📖 Journal',
      };
}
