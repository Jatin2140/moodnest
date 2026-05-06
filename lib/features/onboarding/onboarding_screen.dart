import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/constants/app_strings.dart';
import '../../core/router/app_router.dart';
import '../../providers/auth_provider.dart';
import '../../providers/mood_provider.dart';
import '../../widgets/mn_button.dart';
import '../mood/widgets/mood_picker.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _pageCtrl = PageController();
  int _page = 0;
  MoodType? _selectedMood;

  final _pages = [
    _OnboardingPage(
      icon: Icons.mood_rounded,
      title: AppStrings.ob1Title,
      body: AppStrings.ob1Body,
      gradient: [Color(0xFFF5A65B), Color(0xFFFFF1E0)],
    ),
    _OnboardingPage(
      icon: Icons.auto_awesome_rounded,
      title: AppStrings.ob2Title,
      body: AppStrings.ob2Body,
      gradient: [Color(0xFF8C7BB5), Color(0xFFEDE7F6)],
    ),
    _OnboardingPage(
      icon: Icons.local_florist_rounded,
      title: AppStrings.ob3Title,
      body: AppStrings.ob3Body,
      gradient: [Color(0xFF7FB7BE), Color(0xFFE5F1F2)],
    ),
  ];

  Future<void> _finish(BuildContext context) async {
    if (_selectedMood == null) return;
    final auth = context.read<AuthProvider>();
    final moodP = context.read<MoodProvider>();
    await moodP.logMood(mood: _selectedMood!);
    await auth.completeOnboarding();
    // Navigation is handled reactively by _HomeDecider in app.dart
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView.builder(
                controller: _pageCtrl,
                onPageChanged: (i) => setState(() => _page = i),
                itemCount: _pages.length + 1,
                itemBuilder: (context, i) {
                  if (i < _pages.length) return _OnboardingPageView(page: _pages[i]);
                  return _MoodCapturePage(
                    selected: _selectedMood,
                    onSelect: (m) => setState(() => _selectedMood = m),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      _pages.length + 1,
                      (i) => _Dot(active: i == _page),
                    ),
                  ),
                  const SizedBox(height: 20),
                  if (_page < _pages.length)
                    MnButton(
                      label: 'Next',
                      onPressed: () => _pageCtrl.nextPage(
                        duration: const Duration(milliseconds: 350),
                        curve: Curves.easeOutCubic,
                      ),
                      width: double.infinity,
                    )
                  else
                    MnButton(
                      label: AppStrings.getStarted,
                      onPressed:
                          _selectedMood != null ? () => _finish(context) : null,
                      width: double.infinity,
                      accentMood: _selectedMood,
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OnboardingPage {
  final IconData icon;
  final String title;
  final String body;
  final List<Color> gradient;
  const _OnboardingPage({
    required this.icon,
    required this.title,
    required this.body,
    required this.gradient,
  });
}

class _OnboardingPageView extends StatelessWidget {
  final _OnboardingPage page;
  const _OnboardingPageView({required this.page});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: page.gradient,
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              shape: BoxShape.circle,
            ),
            child: Icon(page.icon, size: 56, color: Colors.white),
          )
              .animate()
              .scale(duration: 500.ms, curve: Curves.elasticOut),
          const SizedBox(height: 40),
          Text(
            page.title,
            style: AppTypography.displayMd.copyWith(
              color:
                  isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
            ),
            textAlign: TextAlign.center,
          ).animate().fadeIn(delay: 200.ms),
          const SizedBox(height: 16),
          Text(
            page.body,
            style: AppTypography.bodyLg.copyWith(
              color: isDark ? AppColors.textMutedDark : AppColors.textMuted,
            ),
            textAlign: TextAlign.center,
          ).animate().fadeIn(delay: 300.ms),
        ],
      ),
    );
  }
}

class _MoodCapturePage extends StatelessWidget {
  final MoodType? selected;
  final ValueChanged<MoodType> onSelect;

  const _MoodCapturePage({required this.selected, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            AppStrings.moodCheckIn,
            style: AppTypography.displayMd.copyWith(
              color:
                  isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
            ),
            textAlign: TextAlign.center,
          ).animate().fadeIn(),
          const SizedBox(height: 12),
          Text(
            'This helps us personalise your first recommendations.',
            style: AppTypography.bodyMd.copyWith(
              color: isDark ? AppColors.textMutedDark : AppColors.textMuted,
            ),
            textAlign: TextAlign.center,
          ).animate().fadeIn(delay: 100.ms),
          const SizedBox(height: 40),
          MoodPicker(selected: selected, onSelect: onSelect),
        ],
      ),
    );
  }
}

class _Dot extends StatelessWidget {
  final bool active;
  const _Dot({required this.active});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      margin: const EdgeInsets.symmetric(horizontal: 4),
      width: active ? 20 : 8,
      height: 8,
      decoration: BoxDecoration(
        color: active
            ? Theme.of(context).colorScheme.primary
            : AppColors.outline,
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
}
