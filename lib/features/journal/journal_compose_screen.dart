import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/constants/app_strings.dart';
import '../../data/repositories/content_repository.dart';
import '../../providers/journal_provider.dart';
import '../../providers/mood_provider.dart';
import '../../providers/goal_provider.dart';
import '../../data/models/goal.dart';
import '../../data/models/journal_entry.dart';
import '../../widgets/mn_button.dart';
import 'widgets/prompt_card.dart';

class JournalComposeScreen extends StatefulWidget {
  final String? promptId;
  final JournalEntry? entryToEdit;
  const JournalComposeScreen({super.key, this.promptId, this.entryToEdit});

  @override
  State<JournalComposeScreen> createState() => _JournalComposeScreenState();
}

class _JournalComposeScreenState extends State<JournalComposeScreen> {
  final _bodyCtrl = TextEditingController();
  String? _selectedPromptId;
  String? _selectedPromptText;
  List<Map<String, dynamic>> _prompts = [];
  bool _loadingPrompts = false;
  bool _saving = false;
  bool _showPrompts = false;

  int get _wordCount {
    final t = _bodyCtrl.text.trim();
    if (t.isEmpty) return 0;
    return t.split(RegExp(r'\s+')).length;
  }

  @override
  void initState() {
    super.initState();
    _bodyCtrl.addListener(() => setState(() {}));
    
    if (widget.entryToEdit != null) {
      _bodyCtrl.text = widget.entryToEdit!.bodyMarkdown;
      if (widget.entryToEdit!.promptId != null) {
        _loadPromptById(widget.entryToEdit!.promptId!);
      }
    } else if (widget.promptId != null) {
      _loadPromptById(widget.promptId!);
    }
  }

  Future<void> _loadPromptById(String id) async {
    final all = await ContentRepository().getJournalPrompts();
    final match = all.where((p) => p['id'] == id).firstOrNull;
    if (match != null && mounted) {
      setState(() {
        _selectedPromptId = id;
        _selectedPromptText = match['text'] as String;
      });
    }
  }

  Future<void> _loadPrompts() async {
    setState(() => _loadingPrompts = true);
    final moodP = context.read<MoodProvider>();
    final moodName = moodP.todayMood?.mood.name ?? 'neutral';
    _prompts = await ContentRepository().getPromptsForMood(moodName);
    if (mounted) setState(() => _loadingPrompts = false);
  }

  Future<void> _save() async {
    if (_bodyCtrl.text.trim().isEmpty) return;
    setState(() => _saving = true);
    final journalP = context.read<JournalProvider>();
    final goalP = context.read<GoalProvider>();
    final moodP = context.read<MoodProvider>();

    if (widget.entryToEdit != null) {
      await journalP.updateEntry(
        entry: widget.entryToEdit!,
        body: _bodyCtrl.text.trim(),
        promptId: _selectedPromptId,
        mood: moodP.todayMood?.mood,
      );
    } else {
      await journalP.addEntry(
        body: _bodyCtrl.text.trim(),
        promptId: _selectedPromptId,
        mood: moodP.todayMood?.mood,
      );
      await goalP.recordProgress(GoalCategory.journal);
    }

    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  @override
  void dispose() {
    _bodyCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    const accent = Color(0xFFF5A65B);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.entryToEdit != null ? 'Edit Entry' : AppStrings.newEntry),
        leading: IconButton(
          icon: const Icon(Icons.close_rounded),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: Center(
              child: Text(
                '$_wordCount ${AppStrings.wordsCount}',
                style: AppTypography.caption.copyWith(
                  color: accent,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Prompt selector bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () async {
                        if (_prompts.isEmpty) await _loadPrompts();
                        setState(() => _showPrompts = !_showPrompts);
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 10),
                        decoration: BoxDecoration(
                          color: isDark
                              ? AppColors.surfaceMutedDark
                              : AppColors.surfaceMuted,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: _selectedPromptId != null
                                ? accent
                                : (isDark
                                    ? AppColors.outlineDark
                                    : AppColors.outline),
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.auto_awesome_rounded,
                                size: 16, color: accent),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                _selectedPromptText ??
                                    AppStrings.usePrompt,
                                style: AppTypography.caption.copyWith(
                                  color: _selectedPromptId != null
                                      ? (isDark
                                          ? AppColors.textPrimaryDark
                                          : AppColors.textPrimary)
                                      : AppColors.textMuted,
                                  fontStyle: _selectedPromptId != null
                                      ? FontStyle.italic
                                      : FontStyle.normal,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Icon(
                              _showPrompts
                                  ? Icons.expand_less_rounded
                                  : Icons.expand_more_rounded,
                              size: 16,
                              color: AppColors.textMuted,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  if (_selectedPromptId != null) ...[
                    const SizedBox(width: 8),
                    IconButton(
                      icon: const Icon(Icons.close_rounded, size: 18),
                      onPressed: () => setState(() {
                        _selectedPromptId = null;
                        _selectedPromptText = null;
                      }),
                      color: AppColors.textMuted,
                    ),
                  ],
                ],
              ),
            ),

            // Prompt list (collapsible)
            if (_showPrompts)
              Container(
                height: 180,
                margin: const EdgeInsets.symmetric(horizontal: 16),
                child: _loadingPrompts
                    ? const Center(child: CircularProgressIndicator(strokeWidth: 2))
                    : ListView.separated(
                        itemCount: _prompts.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 8),
                        itemBuilder: (context, i) {
                          final p = _prompts[i];
                          return PromptCard(
                            text: p['text'] as String,
                            selected: _selectedPromptId == p['id'],
                            onTap: () => setState(() {
                              _selectedPromptId = p['id'] as String;
                              _selectedPromptText = p['text'] as String;
                              _showPrompts = false;
                            }),
                          );
                        },
                      ),
              ).animate().fadeIn(),

            const Divider(height: 1),

            // Text field
            Expanded(
              child: TextField(
                controller: _bodyCtrl,
                maxLines: null,
                expands: true,
                textAlignVertical: TextAlignVertical.top,
                style: AppTypography.bodyLg.copyWith(
                  color: isDark
                      ? AppColors.textPrimaryDark
                      : AppColors.textPrimary,
                  height: 1.7,
                ),
                decoration: InputDecoration(
                  hintText: _selectedPromptText != null
                      ? _selectedPromptText
                      : 'Start writing...',
                  hintStyle: AppTypography.bodyLg.copyWith(
                    color: AppColors.textMuted,
                    fontStyle: FontStyle.italic,
                  ),
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  contentPadding: const EdgeInsets.all(20),
                  filled: false,
                ),
              ),
            ),

            // Save button
            Padding(
              padding: const EdgeInsets.all(16),
              child: MnButton(
                label: AppStrings.saveEntry,
                onPressed:
                    _bodyCtrl.text.trim().isNotEmpty && !_saving ? _save : null,
                isLoading: _saving,
                width: double.infinity,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
