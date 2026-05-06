import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/constants/app_strings.dart';
import '../../core/utils/date_x.dart';
import '../../data/models/mood_entry.dart';
import '../../providers/mood_provider.dart';
import '../../logic/insights/insight_engine.dart';
import '../../widgets/mn_card.dart';
import '../../widgets/mn_section_header.dart';
import '../../widgets/mn_empty_state.dart';
import 'widgets/calm_garden.dart';

class InsightsScreen extends StatelessWidget {
  const InsightsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final moodP = context.watch<MoodProvider>();
    final moods = moodP.moods;

    return Scaffold(
      appBar: AppBar(
        title: Text(AppStrings.insightsTitle),
        automaticallyImplyLeading: false,
      ),
      body: moods.isEmpty
          ? const MnEmptyState(
              title: 'Nothing to show yet',
              body: 'Log a few moods and come back to see your patterns.',
              icon: Icons.bar_chart_outlined,
            )
          : ListView(
              padding: const EdgeInsets.all(20),
              children: [
                // Insight strip
                _InsightStrip(moods: moods),
                const SizedBox(height: 24),

                // Mood trend chart
                MnSectionHeader(title: AppStrings.moodTrend),
                const SizedBox(height: 12),
                MnCard(child: SizedBox(height: 180, child: _MoodChart(moods: moods)))
                    .animate().fadeIn(delay: 100.ms),
                const SizedBox(height: 24),

                // Activity chart
                MnSectionHeader(title: AppStrings.activityChart),
                const SizedBox(height: 12),
                MnCard(child: SizedBox(height: 160, child: _ActivityChart(moods: moods)))
                    .animate().fadeIn(delay: 150.ms),
                const SizedBox(height: 24),

                // Calm Garden
                MnSectionHeader(title: AppStrings.gardenTitle),
                const SizedBox(height: 12),
                MnCard(
                  child: SizedBox(
                    height: 220,
                    child: CalmGarden(moods: moods),
                  ),
                ).animate().fadeIn(delay: 200.ms),
                const SizedBox(height: 40),
              ],
            ),
    );
  }
}

class _InsightStrip extends StatelessWidget {
  final List<MoodEntry> moods;
  const _InsightStrip({required this.moods});

  @override
  Widget build(BuildContext context) {
    final result = InsightEngine.generate(moods);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFF5A65B), Color(0xFFD17A88)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.auto_awesome_rounded, color: Colors.white, size: 16),
              const SizedBox(width: 6),
              Text(
                AppStrings.insightStrip,
                style: AppTypography.caption.copyWith(
                  color: Colors.white.withOpacity(0.8),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            result.headline,
            style: AppTypography.titleMd.copyWith(color: Colors.white),
          ),
          const SizedBox(height: 4),
          Text(
            result.detail,
            style: AppTypography.bodyMd.copyWith(
              color: Colors.white.withOpacity(0.85),
            ),
          ),
        ],
      ),
    ).animate().fadeIn();
  }
}

class _MoodChart extends StatelessWidget {
  final List<MoodEntry> moods;
  const _MoodChart({required this.moods});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final vals = InsightEngine.moodValencePerDay(moods, 14);

    final spots = <FlSpot>[];
    for (int i = 0; i < vals.length; i++) {
      if (vals[i] != null) spots.add(FlSpot(i.toDouble(), vals[i]!));
    }

    if (spots.isEmpty) {
      return const Center(child: Text('Not enough data yet'));
    }

    return LineChart(
      LineChartData(
        minY: 1,
        maxY: 5,
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: 1,
          getDrawingHorizontalLine: (_) => FlLine(
            color: isDark ? AppColors.outlineDark : AppColors.outline,
            strokeWidth: 1,
          ),
        ),
        borderData: FlBorderData(show: false),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              interval: 1,
              reservedSize: 28,
              getTitlesWidget: (v, _) {
                final labels = {1: '😰', 2: '😔', 3: '😐', 4: '😌', 5: '😊'};
                return Text(labels[v.round()] ?? '', style: const TextStyle(fontSize: 12));
              },
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              interval: 2,
              getTitlesWidget: (v, _) {
                final day = DateTime.now().subtract(Duration(days: 13 - v.round()));
                return Text(
                  '${day.day}/${day.month}',
                  style: AppTypography.caption.copyWith(
                    color: isDark ? AppColors.textMutedDark : AppColors.textMuted,
                    fontSize: 10,
                  ),
                );
              },
            ),
          ),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            curveSmoothness: 0.35,
            color: const Color(0xFFF5A65B),
            barWidth: 2.5,
            dotData: FlDotData(
              show: true,
              getDotPainter: (spot, _, __, ___) => FlDotCirclePainter(
                radius: 4,
                color: const Color(0xFFF5A65B),
                strokeWidth: 2,
                strokeColor: Colors.white,
              ),
            ),
            belowBarData: BarAreaData(
              show: true,
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  const Color(0xFFF5A65B).withOpacity(0.25),
                  const Color(0xFFF5A65B).withOpacity(0.0),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ActivityChart extends StatelessWidget {
  final List<MoodEntry> moods;
  const _ActivityChart({required this.moods});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final moodList = moods;

    final counts = List.generate(7, (i) {
      final day = today.subtract(Duration(days: 6 - i));
      return moodList.where((m) {
        final c = m.createdAt;
        return c.year == day.year && c.month == day.month && c.day == day.day;
      }).length;
    });

    final maxCount = counts.reduce((a, b) => a > b ? a : b);
    final chartMaxY = maxCount > 5 ? maxCount.toDouble() : 5.0;

    final bars = List.generate(7, (i) {
      final count = counts[i];
      return BarChartGroupData(
        x: i,
        barRods: [
          BarChartRodData(
            toY: count.toDouble(),
            color: const Color(0xFF8C7BB5),
            width: 20,
            borderRadius: BorderRadius.circular(6),
            backDrawRodData: BackgroundBarChartRodData(
              show: true,
              toY: chartMaxY,
              color: isDark
                  ? AppColors.outlineDark
                  : AppColors.outline,
            ),
          ),
        ],
      );
    });

    return BarChart(
      BarChartData(
        maxY: chartMaxY,
        gridData: const FlGridData(show: false),
        borderData: FlBorderData(show: false),
        titlesData: FlTitlesData(
          leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (v, _) {
                final days = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
                final day = today.subtract(Duration(days: 6 - v.round()));
                final label = days[(day.weekday - 1) % 7];
                return Text(label,
                    style: AppTypography.caption.copyWith(
                      color: isDark ? AppColors.textMutedDark : AppColors.textMuted,
                    ));
              },
            ),
          ),
        ),
        barGroups: bars,
      ),
    );
  }
}
