import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/theme/app_colors.dart';

class MoodPicker extends StatelessWidget {
  final MoodType? selected;
  final ValueChanged<MoodType> onSelect;

  const MoodPicker({super.key, required this.selected, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: MoodType.values.map((mood) {
        return _MoodNode(
          mood: mood,
          isSelected: selected == mood,
          onTap: () => onSelect(mood),
        );
      }).toList(),
    );
  }
}

class _MoodNode extends StatelessWidget {
  final MoodType mood;
  final bool isSelected;
  final VoidCallback onTap;

  const _MoodNode({
    required this.mood,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = MoodPalette.primary[mood]!;
    final softBg = MoodPalette.softBg[mood]!;
    final emoji = MoodPalette.emoji[mood]!;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOutCubic,
        width: isSelected ? 64 : 54,
        height: isSelected ? 64 : 54,
        decoration: BoxDecoration(
          color: isSelected ? softBg : Colors.transparent,
          shape: BoxShape.circle,
          border: Border.all(
            color: isSelected ? color : AppColors.outline,
            width: isSelected ? 2.5 : 1.5,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: color.withOpacity(0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  )
                ]
              : [],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              emoji,
              style: TextStyle(fontSize: isSelected ? 26 : 22),
            ),
          ],
        ),
      )
          .animate(target: isSelected ? 1 : 0)
          .scale(
            begin: const Offset(1, 1),
            end: const Offset(1.1, 1.1),
            duration: 200.ms,
            curve: Curves.easeOutBack,
          ),
    );
  }
}
