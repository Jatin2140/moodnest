import 'package:flutter/material.dart';
import '../../features/auth/login_screen.dart';
import '../../features/auth/signup_screen.dart';
import '../../features/home/home_shell.dart';
import '../../features/onboarding/onboarding_screen.dart';
import '../../features/mood/mood_check_in_screen.dart';
import '../../features/meditation/meditation_list_screen.dart';
import '../../features/meditation/meditation_player_screen.dart';
import '../../features/breathing/breathing_session_screen.dart';
import '../../features/journal/journal_compose_screen.dart';
import '../../features/goals/goal_form_screen.dart';
import '../../features/goals/goals_screen.dart';
import '../../features/reminders/reminders_screen.dart';
import '../../data/models/meditation.dart';
import '../../data/models/breathing_pattern.dart';

class AppRoutes {
  static const login = '/login';
  static const signup = '/signup';
  static const onboarding = '/onboarding';
  static const home = '/home';
  static const moodCheckIn = '/mood-check-in';
  static const meditationList = '/meditations';
  static const meditationPlayer = '/meditation-player';
  static const breathingSession = '/breathing-session';
  static const journalCompose = '/journal-compose';
  static const goalForm = '/goal-form';
  static const goals = '/goals';
  static const reminders = '/reminders';
}

Route<dynamic> onGenerateRoute(RouteSettings settings) {
  switch (settings.name) {
    case AppRoutes.login:
      return _fade(const LoginScreen());
    case AppRoutes.signup:
      return _fade(const SignupScreen());
    case AppRoutes.onboarding:
      return _slide(const OnboardingScreen());
    case AppRoutes.home:
      return _fade(const HomeShell());
    case AppRoutes.moodCheckIn:
      return _modal(const MoodCheckInScreen());
    case AppRoutes.meditationList:
      return _slide(const MeditationListScreen());
    case AppRoutes.meditationPlayer:
      final med = settings.arguments as MeditationModel;
      return _slide(MeditationPlayerScreen(meditation: med));
    case AppRoutes.breathingSession:
      final pattern = settings.arguments as BreathingPattern;
      return _modal(BreathingSessionScreen(pattern: pattern));
    case AppRoutes.journalCompose:
      return _modal(JournalComposeScreen(
        promptId: settings.arguments as String?,
      ));
    case AppRoutes.goalForm:
      return _modal(const GoalFormScreen());
    case AppRoutes.goals:
      return _slide(const GoalsScreen());
    case AppRoutes.reminders:
      return _slide(const RemindersScreen());
    default:
      return _fade(const LoginScreen());
  }
}

PageRoute _fade(Widget page) => PageRouteBuilder(
      pageBuilder: (_, __, ___) => page,
      transitionsBuilder: (_, anim, __, child) =>
          FadeTransition(opacity: anim, child: child),
      transitionDuration: const Duration(milliseconds: 300),
    );

PageRoute _slide(Widget page) => PageRouteBuilder(
      pageBuilder: (_, __, ___) => page,
      transitionsBuilder: (_, anim, __, child) => SlideTransition(
        position: Tween<Offset>(begin: const Offset(1, 0), end: Offset.zero)
            .animate(CurvedAnimation(parent: anim, curve: Curves.easeOutCubic)),
        child: child,
      ),
      transitionDuration: const Duration(milliseconds: 350),
    );

PageRoute _modal(Widget page) => PageRouteBuilder(
      pageBuilder: (_, __, ___) => page,
      transitionsBuilder: (_, anim, __, child) => SlideTransition(
        position: Tween<Offset>(begin: const Offset(0, 1), end: Offset.zero)
            .animate(CurvedAnimation(parent: anim, curve: Curves.easeOutCubic)),
        child: child,
      ),
      transitionDuration: const Duration(milliseconds: 400),
      fullscreenDialog: true,
    );
