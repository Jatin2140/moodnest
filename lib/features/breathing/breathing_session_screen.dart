import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/constants/app_strings.dart';
import '../../data/models/breathing_pattern.dart';
import '../../providers/recommendation_provider.dart';
import '../../providers/goal_provider.dart';
import '../../data/models/goal.dart';

class BreathingSessionScreen extends StatefulWidget {
  final BreathingPattern pattern;
  const BreathingSessionScreen({super.key, required this.pattern});

  @override
  State<BreathingSessionScreen> createState() => _BreathingSessionScreenState();
}

class _BreathingSessionScreenState extends State<BreathingSessionScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _orbCtrl;
  late Animation<double> _orbAnim;

  int _phaseIndex = 0;
  int _secondsLeft = 0;
  int _cyclesDone = 0;
  bool _running = false;
  Timer? _timer;

  BreathingPhase get _currentPhase =>
      widget.pattern.phases[_phaseIndex % widget.pattern.phases.length];

  @override
  void initState() {
    super.initState();
    _orbCtrl = AnimationController(vsync: this);
    _orbAnim = Tween<double>(begin: 0.6, end: 1.0).animate(
      CurvedAnimation(parent: _orbCtrl, curve: Curves.easeInOut),
    );
    _secondsLeft = _currentPhase.seconds;
  }

  void _start() {
    setState(() => _running = true);
    _animatePhase();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => _tick());
  }

  void _stop() {
    _timer?.cancel();
    _orbCtrl.stop();
    setState(() {
      _running = false;
      _phaseIndex = 0;
      _cyclesDone = 0;
      _secondsLeft = _currentPhase.seconds;
    });
    _orbCtrl.value = 0.6;
  }

  void _animatePhase() {
    _orbCtrl.stop();
    final phase = _currentPhase;
    if (phase.isHold) {
      // Hold: keep orb at current position
      return;
    }
    final isInhale = phase.label.toLowerCase().contains('in');
    _orbCtrl.duration = Duration(seconds: phase.seconds);
    if (isInhale) {
      _orbCtrl.forward(from: _orbCtrl.value);
    } else {
      _orbCtrl.reverse(from: _orbCtrl.value);
    }
  }

  void _tick() {
    if (_secondsLeft > 1) {
      setState(() => _secondsLeft--);
    } else {
      HapticFeedback.lightImpact();
      _nextPhase();
    }
  }

  void _nextPhase() {
    final nextIndex = _phaseIndex + 1;
    final wraps = nextIndex >= widget.pattern.phases.length;
    if (wraps) {
      final newCycles = _cyclesDone + 1;
      if (newCycles >= widget.pattern.recommendedCycles) {
        _finish();
        return;
      }
      setState(() {
        _cyclesDone = newCycles;
        _phaseIndex = 0;
      });
    } else {
      setState(() => _phaseIndex = nextIndex);
    }
    setState(() => _secondsLeft = _currentPhase.seconds);
    _animatePhase();
  }

  void _finish() {
    _timer?.cancel();
    _orbCtrl.stop();
    final recP = context.read<RecommendationProvider>();
    final goalP = context.read<GoalProvider>();
    recP.recordCompletion(widget.pattern.id, 1.0);
    goalP.recordProgress(GoalCategory.breathe);
    setState(() => _running = false);
    _showDoneDialog();
  }

  void _showDoneDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Session complete 🌿'),
        content: Text(
          'You completed ${widget.pattern.recommendedCycles} cycles of ${widget.pattern.name}. Well done!',
          style: AppTypography.bodyMd,
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop();
            },
            child: const Text('Done'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              setState(() {
                _phaseIndex = 0;
                _cyclesDone = 0;
                _secondsLeft = _currentPhase.seconds;
              });
            },
            child: const Text('Go again'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    _orbCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    const accent = Color(0xFF8C7BB5);
    final total = widget.pattern.recommendedCycles;
    final phase = _currentPhase;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: isDark
                ? [AppColors.surfaceDark, const Color(0xFF2A2240)]
                : [const Color(0xFFEDE7F6), const Color(0xFFF8F7FC)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Top bar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.close_rounded),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                    const Spacer(),
                    Text(
                      widget.pattern.name,
                      style: AppTypography.titleMd.copyWith(
                        color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
                      ),
                    ),
                    const Spacer(),
                    // Cycle counter
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: accent.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '$_cyclesDone/$total',
                        style: AppTypography.caption.copyWith(
                          color: accent,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const Spacer(),

              // Breathing orb (CustomPainter)
              AnimatedBuilder(
                animation: _orbAnim,
                builder: (context, _) => CustomPaint(
                  size: const Size(240, 240),
                  painter: _OrbPainter(
                    progress: _running ? _orbAnim.value : 0.6,
                    accent: accent,
                    isHold: phase.isHold,
                  ),
                  child: SizedBox(
                    width: 240,
                    height: 240,
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            _running ? phase.label : 'Ready',
                            style: AppTypography.titleLg.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          if (_running)
                            Text(
                              '$_secondsLeft',
                              style: AppTypography.displayMd.copyWith(
                                color: Colors.white.withOpacity(0.9),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 32),

              // Phase pattern dots
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: widget.pattern.phases.asMap().entries.map((e) {
                  final active = _running && e.key == _phaseIndex % widget.pattern.phases.length;
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: active ? 24 : 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: active ? accent : accent.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  );
                }).toList(),
              ),

              const SizedBox(height: 16),

              Text(
                widget.pattern.description,
                style: AppTypography.bodyMd.copyWith(
                  color: isDark ? AppColors.textMutedDark : AppColors.textMuted,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
              ),

              const Spacer(),

              // Controls
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 32),
                child: _running
                    ? _StopButton(onTap: _stop)
                    : _StartButton(onTap: _start, accent: accent),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _OrbPainter extends CustomPainter {
  final double progress;
  final Color accent;
  final bool isHold;

  const _OrbPainter({
    required this.progress,
    required this.accent,
    required this.isHold,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final maxRadius = size.width / 2;
    final radius = maxRadius * (0.5 + 0.5 * progress);

    // Outer glow
    final glowPaint = Paint()
      ..color = accent.withOpacity(0.15)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, radius + 20, glowPaint);

    // Mid ring
    final midPaint = Paint()
      ..color = accent.withOpacity(0.25)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, radius + 8, midPaint);

    // Main orb gradient
    final gradient = RadialGradient(
      colors: [
        accent.withOpacity(0.95),
        accent.withOpacity(0.7),
      ],
    ).createShader(Rect.fromCircle(center: center, radius: radius));

    final orbPaint = Paint()
      ..shader = gradient
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, radius, orbPaint);

    // Hold pulse ring
    if (isHold) {
      final holdPaint = Paint()
        ..color = Colors.white.withOpacity(0.4)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2;
      canvas.drawCircle(center, radius + 4, holdPaint);
    }
  }

  @override
  bool shouldRepaint(_OrbPainter old) =>
      old.progress != progress || old.isHold != isHold;
}

class _StartButton extends StatelessWidget {
  final VoidCallback onTap;
  final Color accent;
  const _StartButton({required this.onTap, required this.accent});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: 56,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [accent, accent.withOpacity(0.7)],
          ),
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: accent.withOpacity(0.4),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Center(
          child: Text(
            AppStrings.startSession,
            style: AppTypography.button.copyWith(color: Colors.white),
          ),
        ),
      ),
    );
  }
}

class _StopButton extends StatelessWidget {
  final VoidCallback onTap;
  const _StopButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: 56,
        decoration: BoxDecoration(
          color: AppColors.outline,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Center(
          child: Text(
            AppStrings.stopSession,
            style: AppTypography.button.copyWith(color: AppColors.textMuted),
          ),
        ),
      ),
    );
  }
}
