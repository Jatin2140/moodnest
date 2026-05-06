import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_strings.dart';
import '../../core/theme/app_colors.dart';
import '../../providers/connectivity_provider.dart';
import '../home/dashboard_screen.dart';
import '../meditation/meditation_list_screen.dart';
import '../breathing/breathing_list_screen.dart';
import '../journal/journal_list_screen.dart';
import '../insights/insights_screen.dart';

class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _tab = 0;

  final _tabs = const [
    DashboardScreen(),
    MeditationListScreen(),
    BreathingListScreen(),
    JournalListScreen(),
    InsightsScreen(),
  ];

  final _navItems = const [
    BottomNavigationBarItem(
      icon: Icon(Icons.home_outlined),
      activeIcon: Icon(Icons.home_rounded),
      label: AppStrings.home,
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.self_improvement_outlined),
      activeIcon: Icon(Icons.self_improvement_rounded),
      label: AppStrings.meditate,
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.air_outlined),
      activeIcon: Icon(Icons.air_rounded),
      label: AppStrings.breathe,
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.book_outlined),
      activeIcon: Icon(Icons.book_rounded),
      label: AppStrings.journal,
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.bar_chart_outlined),
      activeIcon: Icon(Icons.bar_chart_rounded),
      label: AppStrings.insights,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isOnline = context.select((ConnectivityProvider c) => c.isOnline);

    return Scaffold(
      body: Column(
        children: [
          if (!isOnline)
            Material(
              color: AppColors.warning.withOpacity(0.15),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 16),
                child: Row(
                  children: [
                    Icon(Icons.wifi_off_rounded,
                        size: 16, color: AppColors.warning),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        AppStrings.offlineBanner,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.warning,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          Expanded(child: _tabs[_tab]),
        ],
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(
              color: isDark ? AppColors.outlineDark : AppColors.outline,
            ),
          ),
        ),
        child: BottomNavigationBar(
          currentIndex: _tab,
          onTap: (i) => setState(() => _tab = i),
          items: _navItems,
        ),
      ),
    );
  }
}
