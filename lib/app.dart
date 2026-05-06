import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/theme/app_theme.dart';
import 'core/router/app_router.dart';
import 'providers/auth_provider.dart';
import 'providers/connectivity_provider.dart';
import 'providers/mood_provider.dart';
import 'providers/journal_provider.dart';
import 'providers/goal_provider.dart';
import 'providers/reminder_provider.dart';
import 'providers/recommendation_provider.dart';
import 'features/auth/login_screen.dart';
import 'features/home/home_shell.dart';
import 'features/onboarding/onboarding_screen.dart';

class MoodNestApp extends StatelessWidget {
  const MoodNestApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ConnectivityProvider()),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
      ],
      child: Consumer<AuthProvider>(
        builder: (context, auth, _) {
          Widget buildApp() {
            return Consumer<AuthProvider>(
              builder: (context, authP, _) {
                final isDark = authP.profile?.darkMode ?? false;
                return MaterialApp(
                  title: 'MoodNest',
                  debugShowCheckedModeBanner: false,
                  theme: AppTheme.light,
                  darkTheme: AppTheme.dark,
                  themeMode: isDark ? ThemeMode.dark : ThemeMode.light,
                  onGenerateRoute: onGenerateRoute,
                  home: _HomeDecider(auth: authP),
                );
              },
            );
          }

          if (auth.uid != null) {
            return MultiProvider(
              providers: [
                ChangeNotifierProvider(
                  create: (_) => MoodProvider(uid: auth.uid!),
                ),
                ChangeNotifierProvider(
                  create: (_) => JournalProvider(uid: auth.uid!),
                ),
                ChangeNotifierProvider(
                  create: (_) => GoalProvider(uid: auth.uid!),
                ),
                ChangeNotifierProvider(
                  create: (_) => ReminderProvider(uid: auth.uid!),
                ),
                ChangeNotifierProvider(
                  create: (_) => RecommendationProvider(uid: auth.uid!),
                ),
              ],
              child: buildApp(),
            );
          }

          return buildApp();
        },
      ),
    );
  }
}

class _HomeDecider extends StatelessWidget {
  final AuthProvider auth;
  const _HomeDecider({required this.auth});

  @override
  Widget build(BuildContext context) {
    return switch (auth.status) {
      AuthStatus.unknown => const _SplashScreen(),
      AuthStatus.unauthenticated => const LoginScreen(),
      AuthStatus.authenticated => auth.profile?.onboardingDone == true
          ? const HomeShell()
          : const OnboardingScreen(),
    };
  }
}

class _SplashScreen extends StatelessWidget {
  const _SplashScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF1E0),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
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
                borderRadius: BorderRadius.circular(24),
              ),
              child: const Icon(Icons.spa_rounded, size: 44, color: Colors.white),
            ),
            const SizedBox(height: 20),
            const Text(
              'MoodNest',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w700,
                color: Color(0xFF1A1825),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
