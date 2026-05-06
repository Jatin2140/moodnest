import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/constants/app_strings.dart';
import '../../core/router/app_router.dart';
import '../../providers/auth_provider.dart';
import '../../providers/journal_provider.dart';
import '../../widgets/mn_button.dart';
import '../../widgets/mn_card.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _editingName = false;
  late TextEditingController _nameCtrl;

  @override
  void initState() {
    super.initState();
    final auth = context.read<AuthProvider>();
    _nameCtrl =
        TextEditingController(text: auth.profile?.displayName ?? 'Friend');
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    super.dispose();
  }

  Future<void> _exportJournal(BuildContext context) async {
    final journalP = context.read<JournalProvider>();
    final text = journalP.exportText();
    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/moodnest_journal.txt');
    await file.writeAsString(text);
    await Share.shareXFiles([XFile(file.path)],
        subject: 'My MoodNest Journal');
  }

  Future<void> _confirmDelete(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Delete account?'),
        content: Text(AppStrings.deleteAccountConfirm,
            style: AppTypography.bodyMd),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(AppStrings.deleteAccount,
                style: const TextStyle(color: AppColors.danger)),
          ),
        ],
      ),
    );
    if (confirmed == true && mounted) {
      final auth = context.read<AuthProvider>();
      await auth.deleteAccount();
      if (mounted) {
        Navigator.of(context)
            .pushNamedAndRemoveUntil(AppRoutes.login, (_) => false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final profile = auth.profile;
    final name = profile?.displayName ?? 'Friend';

    return Scaffold(
      appBar: AppBar(
        title: Text(AppStrings.profileTitle),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // Avatar
          Center(
            child: Column(
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFF5A65B), Color(0xFF8C7BB5)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      name.substring(0, 1).toUpperCase(),
                      style: AppTypography.displayMd
                          .copyWith(color: Colors.white),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                if (_editingName)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: 180,
                        child: TextField(
                          controller: _nameCtrl,
                          autofocus: true,
                          textAlign: TextAlign.center,
                          style: AppTypography.titleLg,
                          decoration: const InputDecoration(
                            contentPadding: EdgeInsets.symmetric(
                                horizontal: 12, vertical: 8),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        icon: const Icon(Icons.check_rounded),
                        color: AppColors.success,
                        onPressed: () async {
                          await auth.updateDisplayName(_nameCtrl.text.trim());
                          setState(() => _editingName = false);
                        },
                      ),
                    ],
                  )
                else
                  GestureDetector(
                    onTap: () => setState(() => _editingName = true),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(name, style: AppTypography.titleLg),
                        const SizedBox(width: 6),
                        const Icon(Icons.edit_outlined,
                            size: 16, color: AppColors.textMuted),
                      ],
                    ),
                  ),
                if (profile?.email.isNotEmpty == true)
                  Text(
                    profile!.email,
                    style: AppTypography.bodyMd
                        .copyWith(color: AppColors.textMuted),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 32),

          // Settings card
          MnCard(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                _SettingsTile(
                  icon: Icons.dark_mode_outlined,
                  title: AppStrings.darkMode,
                  trailing: Switch(
                    value: profile?.darkMode ?? false,
                    onChanged: (v) => auth.updateDarkMode(v),
                    activeColor: Theme.of(context).colorScheme.primary,
                  ),
                ),
                const Divider(height: 1),
                _SettingsTile(
                  icon: Icons.notifications_outlined,
                  title: AppStrings.remindersTitle,
                  onTap: () =>
                      Navigator.of(context).pushNamed(AppRoutes.reminders),
                  trailing: const Icon(Icons.chevron_right_rounded,
                      color: AppColors.textMuted),
                ),
                const Divider(height: 1),
                _SettingsTile(
                  icon: Icons.file_download_outlined,
                  title: AppStrings.exportJournal,
                  onTap: () => _exportJournal(context),
                  trailing: const Icon(Icons.chevron_right_rounded,
                      color: AppColors.textMuted),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          MnButton(
            label: AppStrings.signOut,
            variant: MnButtonVariant.secondary,
            icon: Icons.logout_rounded,
            onPressed: () async {
              await auth.signOut();
              if (mounted) {
                Navigator.of(context)
                    .pushNamedAndRemoveUntil(AppRoutes.login, (_) => false);
              }
            },
            width: double.infinity,
          ),
          const SizedBox(height: 12),
          MnButton(
            label: AppStrings.deleteAccount,
            variant: MnButtonVariant.ghost,
            onPressed: () => _confirmDelete(context),
            width: double.infinity,
          ),
          const SizedBox(height: 40),
          Center(
            child: Text(
              'MoodNest v1.0 · Your nest of calm',
              style: AppTypography.caption
                  .copyWith(color: AppColors.textMuted),
            ),
          ),
        ],
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final Widget? trailing;
  final VoidCallback? onTap;

  const _SettingsTile({
    required this.icon,
    required this.title,
    this.trailing,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return ListTile(
      onTap: onTap,
      leading: Icon(icon,
          color: isDark ? AppColors.textMutedDark : AppColors.textMuted),
      title: Text(title, style: AppTypography.bodyMd),
      trailing: trailing,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
    );
  }
}
