import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/constants/app_strings.dart';
import '../../core/router/app_router.dart';
import '../../data/models/journal_entry.dart';
import '../../providers/journal_provider.dart';
import '../../widgets/mn_empty_state.dart';
import '../../widgets/mn_loading.dart';
import '../../widgets/mn_card.dart';
import 'journal_compose_screen.dart';

class JournalListScreen extends StatelessWidget {
  const JournalListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final journalP = context.watch<JournalProvider>();

    return Scaffold(
      appBar: AppBar(
        title: Text(AppStrings.journalTitle),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_note_rounded),
            tooltip: AppStrings.newEntry,
            onPressed: () =>
                Navigator.of(context).pushNamed(AppRoutes.journalCompose),
          ),
        ],
      ),
      body: journalP.isLoading
          ? const Padding(padding: EdgeInsets.all(20), child: MnLoading())
          : journalP.entries.isEmpty
              ? MnEmptyState(
                  title: AppStrings.noJournal,
                  body: AppStrings.noJournalSub,
                  icon: Icons.book_outlined,
                  ctaLabel: AppStrings.newEntry,
                  onCta: () =>
                      Navigator.of(context).pushNamed(AppRoutes.journalCompose),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(20),
                  itemCount: journalP.entries.length + 1,
                  itemBuilder: (context, i) {
                    if (i == 0) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: Text(
                          AppStrings.journalSub,
                          style: AppTypography.bodyMd.copyWith(
                            color: isDark
                                ? AppColors.textMutedDark
                                : AppColors.textMuted,
                          ),
                        ).animate().fadeIn(),
                      );
                    }
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _JournalTile(entry: journalP.entries[i - 1]),
                    );
                  },
                ),
      floatingActionButton: journalP.entries.isNotEmpty
          ? FloatingActionButton(
              onPressed: () =>
                  Navigator.of(context).pushNamed(AppRoutes.journalCompose),
              backgroundColor: const Color(0xFFF5A65B),
              child: const Icon(Icons.add_rounded, color: Colors.white),
            )
          : null,
    );
  }
}

class _JournalTile extends StatelessWidget {
  final JournalEntry entry;
  const _JournalTile({required this.entry});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final date = DateFormat('MMM d · h:mm a').format(entry.createdAt.toLocal());

    return MnCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                date,
                style: AppTypography.caption.copyWith(
                  color: isDark ? AppColors.textMutedDark : AppColors.textMuted,
                ),
              ),
              const Spacer(),
              Text(
                '${entry.wordCount} ${AppStrings.wordsCount}',
                style: AppTypography.caption.copyWith(
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(width: 8),
              PopupMenuButton<String>(
                icon: Icon(Icons.more_horiz_rounded,
                    size: 20,
                    color: isDark ? AppColors.textMutedDark : AppColors.textMuted),
                onSelected: (val) {
                  if (val == 'edit') {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => JournalComposeScreen(entryToEdit: entry),
                      ),
                    );
                  } else if (val == 'delete') {
                    _confirmDelete(context, entry);
                  }
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'edit',
                    child: Row(
                      children: [
                        Icon(Icons.edit_rounded, size: 18),
                        SizedBox(width: 8),
                        Text('Edit'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(Icons.delete_outline_rounded,
                            size: 18, color: AppColors.danger),
                        SizedBox(width: 8),
                        Text('Delete', style: TextStyle(color: AppColors.danger)),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            entry.bodyMarkdown,
            style: AppTypography.bodyMd.copyWith(
              color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
            ),
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    ).animate().fadeIn(delay: 60.ms);
  }

  Future<void> _confirmDelete(BuildContext context, JournalEntry entry) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Journal'),
        content: const Text('Are you sure you want to delete this journal entry? This cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: TextButton.styleFrom(foregroundColor: AppColors.danger),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm == true && context.mounted) {
      final p = context.read<JournalProvider>();
      await p.deleteEntry(entry.id);
    }
  }
}
