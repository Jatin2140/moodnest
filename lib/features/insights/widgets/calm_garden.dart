import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/date_x.dart';
import '../../../data/models/mood_entry.dart';

class CalmGarden extends StatefulWidget {
  final List<MoodEntry> moods;
  final bool isPreview;

  const CalmGarden({super.key, required this.moods, this.isPreview = false});

  @override
  State<CalmGarden> createState() => _CalmGardenState();
}

class _CalmGardenState extends State<CalmGarden>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  int? _tappedFlower;

  List<_FlowerData> get _flowers => _buildFlowers(widget.moods);

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  List<_FlowerData> _buildFlowers(List<MoodEntry> moods) {
    if (moods.isEmpty) return [];

    // Group moods into 3-day buckets; each completed streak → one flower
    final sorted = [...moods]..sort((a, b) => a.createdAt.compareTo(b.createdAt));
    final flowers = <_FlowerData>[];
    final buckets = <String, List<MoodEntry>>{};

    for (final m in sorted) {
      final day = m.createdAt.startOfDay;
      final bucketKey =
          day.subtract(Duration(days: day.difference(sorted.first.createdAt.startOfDay).inDays % 3)).toIso8601String();
      buckets.putIfAbsent(bucketKey, () => []).add(m);
    }

    // One flower per 3-entry bucket
    int idx = 0;
    for (final bucket in buckets.values) {
      if (bucket.isNotEmpty) {
        // Dominant mood in this bucket
        final counts = <int, int>{};
        for (final m in bucket) {
          counts[m.moodIndex] = (counts[m.moodIndex] ?? 0) + 1;
        }
        final dominantIdx = counts.entries
            .reduce((a, b) => a.value > b.value ? a : b)
            .key;
        final mood = MoodType.values[dominantIdx];
        final date = bucket.first.createdAt;
        flowers.add(_FlowerData(index: idx, mood: mood, date: date));
        idx++;
      }
    }

    return flowers.take(widget.isPreview ? 5 : 20).toList();
  }

  @override
  Widget build(BuildContext context) {
    final flowers = _flowers;

    if (flowers.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('🌱', style: TextStyle(fontSize: 36)),
            const SizedBox(height: 8),
            Text(
              'Log moods to grow your garden',
              style: TextStyle(
                fontSize: 13,
                color: AppColors.textMuted,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return AnimatedBuilder(
      animation: _ctrl,
      builder: (context, _) {
        return GestureDetector(
          onTapUp: (details) {
            // Find which flower was tapped
            final box = context.findRenderObject() as RenderBox?;
            if (box == null) return;
            final localPos = details.localPosition;
            final size = box.size;
            for (int i = 0; i < flowers.length; i++) {
              final pos = _flowerPosition(i, flowers.length, size);
              if ((pos - localPos).distance < 28) {
                setState(() =>
                    _tappedFlower = _tappedFlower == i ? null : i);
                return;
              }
            }
            setState(() => _tappedFlower = null);
          },
          child: CustomPaint(
            painter: _GardenPainter(
              flowers: flowers,
              animValue: _ctrl.value,
              tappedFlower: _tappedFlower,
            ),
            child: _tappedFlower != null && _tappedFlower! < flowers.length
                ? _Tooltip(
                    flower: flowers[_tappedFlower!],
                    offset: Offset.zero,
                  )
                : null,
          ),
        );
      },
    );
  }

  static Offset _flowerPosition(int i, int total, Size size) {
    const cols = 5;
    final col = i % cols;
    final row = i ~/ cols;
    final cellW = size.width / cols;
    final cellH = size.height / math.max(1, (total / cols).ceil());
    return Offset(
      cellW * col + cellW / 2,
      cellH * row + cellH / 2 + 10,
    );
  }
}

class _GardenPainter extends CustomPainter {
  final List<_FlowerData> flowers;
  final double animValue;
  final int? tappedFlower;

  const _GardenPainter({
    required this.flowers,
    required this.animValue,
    this.tappedFlower,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Grass strip at bottom
    final grassPaint = Paint()
      ..color = const Color(0xFFD4EDD4).withOpacity(0.6)
      ..style = PaintingStyle.fill;
    final grassRect = Rect.fromLTWH(0, size.height - 20, size.width, 20);
    canvas.drawRRect(
      RRect.fromRectAndRadius(grassRect, const Radius.circular(10)),
      grassPaint,
    );

    for (int i = 0; i < flowers.length; i++) {
      final f = flowers[i];
      final pos = _CalmGardenState._flowerPosition(i, flowers.length, size);
      final sway = math.sin(animValue * 2 * math.pi + i * 0.8) * 2.0;
      final scale = tappedFlower == i ? 1.3 : 1.0;

      _drawFlower(canvas, pos, f.mood, sway, scale);
    }
  }

  void _drawFlower(
      Canvas canvas, Offset center, MoodType mood, double sway, double scale) {
    final color = MoodPalette.primary[mood]!;
    final soft = MoodPalette.softBg[mood]!;

    // Stem
    final stemPaint = Paint()
      ..color = const Color(0xFF6BBF6B).withOpacity(0.8)
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    canvas.drawLine(
      Offset(center.dx + sway, center.dy + 14 * scale),
      Offset(center.dx + sway * 0.3, center.dy + 28 * scale),
      stemPaint,
    );

    canvas.save();
    canvas.translate(center.dx + sway, center.dy);
    canvas.scale(scale, scale);

    // Petals (5 around center)
    final petalPaint = Paint()..color = color.withOpacity(0.85);
    for (int p = 0; p < 5; p++) {
      final angle = (p / 5) * 2 * math.pi - math.pi / 2;
      final petalCenter = Offset(math.cos(angle) * 8, math.sin(angle) * 8);
      canvas.drawOval(
        Rect.fromCenter(center: petalCenter, width: 10, height: 14),
        petalPaint,
      );
    }

    // Center
    final centerPaint = Paint()..color = soft;
    canvas.drawCircle(Offset.zero, 7, centerPaint);
    final dotPaint = Paint()..color = color;
    canvas.drawCircle(Offset.zero, 4, dotPaint);

    canvas.restore();
  }

  @override
  bool shouldRepaint(_GardenPainter old) =>
      old.animValue != animValue || old.tappedFlower != tappedFlower;
}

class _FlowerData {
  final int index;
  final MoodType mood;
  final DateTime date;

  const _FlowerData({
    required this.index,
    required this.mood,
    required this.date,
  });
}

class _Tooltip extends StatelessWidget {
  final _FlowerData flower;
  final Offset offset;

  const _Tooltip({required this.flower, required this.offset});

  @override
  Widget build(BuildContext context) {
    final label = MoodPalette.label[flower.mood]!;
    final emoji = MoodPalette.emoji[flower.mood]!;
    final date = flower.date.friendlyDate;

    return Align(
      alignment: Alignment.topCenter,
      child: Container(
        margin: const EdgeInsets.only(top: 4),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: MoodPalette.primary[flower.mood]!.withOpacity(0.9),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          '$emoji $label · $date',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
