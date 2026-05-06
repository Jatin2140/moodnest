import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../core/theme/app_colors.dart';

class MnLoading extends StatelessWidget {
  final int itemCount;

  const MnLoading({super.key, this.itemCount = 3});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final base = isDark ? AppColors.outlineDark : AppColors.outline;
    final shimmer = isDark
        ? AppColors.surfaceMutedDark
        : const Color(0xFFEEECF5);

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: itemCount,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (_, i) => _ShimmerCard(base: base, shimmer: shimmer, index: i),
    );
  }
}

class _ShimmerCard extends StatelessWidget {
  final Color base;
  final Color shimmer;
  final int index;

  const _ShimmerCard({
    required this.base,
    required this.shimmer,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 80,
      decoration: BoxDecoration(
        color: base,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              height: 14,
              width: double.infinity,
              decoration: BoxDecoration(
                color: shimmer,
                borderRadius: BorderRadius.circular(7),
              ),
            ),
            const SizedBox(height: 8),
            Container(
              height: 12,
              width: 160,
              decoration: BoxDecoration(
                color: shimmer,
                borderRadius: BorderRadius.circular(6),
              ),
            ),
          ],
        ),
      ),
    )
        .animate(delay: Duration(milliseconds: index * 80))
        .shimmer(duration: 1200.ms, color: shimmer.withOpacity(0.6));
  }
}

class MnLoadingSpinner extends StatelessWidget {
  const MnLoadingSpinner({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: CircularProgressIndicator(
        strokeWidth: 2.5,
        color: Theme.of(context).colorScheme.primary,
      ),
    );
  }
}
