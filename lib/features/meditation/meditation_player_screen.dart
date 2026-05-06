import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'package:audioplayers/audioplayers.dart';
import 'dart:async';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../data/models/meditation.dart';
import '../../providers/recommendation_provider.dart';
import '../../providers/goal_provider.dart';
import '../../data/models/goal.dart';

class MeditationPlayerScreen extends StatefulWidget {
  final MeditationModel meditation;
  const MeditationPlayerScreen({super.key, required this.meditation});

  @override
  State<MeditationPlayerScreen> createState() => _MeditationPlayerScreenState();
}

class _MeditationPlayerScreenState extends State<MeditationPlayerScreen>
    with SingleTickerProviderStateMixin {
  final _player = AudioPlayer();
  bool _playing = false;
  bool _completed = false;
  Duration _position = Duration.zero;
  Duration _duration = Duration.zero;
  late AnimationController _pulseCtrl;
  Timer? _fallbackTimer;

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);

    _player.setReleaseMode(ReleaseMode.loop);
    _duration = Duration(seconds: widget.meditation.durationSeconds);

    _startPlayback();
  }

  bool _noAudio = false;

  void _startTimer() {
    _fallbackTimer?.cancel();
    _fallbackTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!_playing) return;
      if (mounted) {
        setState(() {
          _position += const Duration(seconds: 1);
          if (_position >= _duration) {
            _position = _duration;
            _playing = false;
            _player.stop();
            if (!_completed) {
              _completed = true;
              _onCompleted();
            }
            timer.cancel();
          } else if (_position.inSeconds >= _duration.inSeconds * 0.8 && !_completed) {
            _completed = true;
            _onCompleted();
          }
        });
      }
    });
  }

  Future<void> _startPlayback() async {
    try {
      await _player.play(AssetSource(
        widget.meditation.audioAsset.replaceFirst('assets/', ''),
      ));
      if (mounted) setState(() {
        _playing = true;
        _noAudio = false;
      });
      _startTimer();
    } catch (_) {
      // Audio asset not bundled
      if (mounted) {
        setState(() {
          _noAudio = true;
          _playing = true;
        });
        _startTimer();
      }
    }
  }

  Future<void> _togglePlay() async {
    HapticFeedback.lightImpact();
    if (!_noAudio) {
      if (_playing) {
        await _player.pause();
      } else {
        await _player.resume();
      }
    }
    if (mounted) setState(() => _playing = !_playing);
  }

  Future<void> _skip(int seconds) async {
    HapticFeedback.lightImpact();
    final target = _position + Duration(seconds: seconds);
    final clamped = target.isNegative
        ? Duration.zero
        : (_duration > Duration.zero && target > _duration ? _duration : target);
    
    if (mounted) setState(() => _position = clamped);
  }

  void _onCompleted() {
    final recP = context.read<RecommendationProvider>();
    final goalP = context.read<GoalProvider>();
    recP.recordCompletion(widget.meditation.id, 0.8);
    goalP.recordProgress(GoalCategory.meditate);
  }

  @override
  void dispose() {
    _fallbackTimer?.cancel();
    _player.dispose();
    _pulseCtrl.dispose();
    super.dispose();
  }

  String _fmt(Duration d) {
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final progress = _duration.inSeconds > 0
        ? _position.inSeconds / _duration.inSeconds
        : 0.0;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFE5F1F2), Color(0xFFF8F7FC)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // App bar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.keyboard_arrow_down_rounded, size: 28),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                    const Spacer(),
                    Text(
                      widget.meditation.category.toUpperCase(),
                      style: AppTypography.caption.copyWith(
                        color: const Color(0xFF7FB7BE),
                        letterSpacing: 1.5,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const Spacer(),
                    const SizedBox(width: 48),
                  ],
                ),
              ),

              const Spacer(),

              // Pulsing orb
              AnimatedBuilder(
                animation: _pulseCtrl,
                builder: (context, _) {
                  final scale = 1.0 + (_playing ? _pulseCtrl.value * 0.12 : 0);
                  return Transform.scale(
                    scale: scale,
                    child: Container(
                      width: 200,
                      height: 200,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [
                            const Color(0xFF7FB7BE).withOpacity(0.9),
                            const Color(0xFF7FB7BE).withOpacity(0.3),
                          ],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF7FB7BE)
                                .withOpacity(0.4 * (_playing ? 1.0 : 0.3)),
                            blurRadius: 40,
                            spreadRadius: 10,
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.self_improvement_rounded,
                        size: 80,
                        color: Colors.white,
                      ),
                    ),
                  );
                },
              ).animate().scale(
                    duration: 600.ms,
                    curve: Curves.elasticOut,
                  ),

              if (_noAudio)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF3E0),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.music_off_rounded, size: 18, color: Color(0xFFF5A65B)),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Audio files not available. Use this as a timed silent meditation.',
                            style: AppTypography.caption.copyWith(color: const Color(0xFF5D4037)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

              const SizedBox(height: 48),

              // Title & description
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Column(
                  children: [
                    Text(
                      widget.meditation.title,
                      style: AppTypography.displayMd.copyWith(
                        color: isDark
                            ? AppColors.textPrimaryDark
                            : AppColors.textPrimary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      widget.meditation.description,
                      style: AppTypography.bodyMd.copyWith(
                        color: isDark
                            ? AppColors.textMutedDark
                            : AppColors.textMuted,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 40),

              // Progress bar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Column(
                  children: [
                    SliderTheme(
                      data: SliderTheme.of(context).copyWith(
                        trackHeight: 3,
                        thumbShape:
                            const RoundSliderThumbShape(enabledThumbRadius: 6),
                        activeTrackColor: const Color(0xFF7FB7BE),
                        inactiveTrackColor: AppColors.outline,
                        thumbColor: const Color(0xFF7FB7BE),
                        overlayColor:
                            const Color(0xFF7FB7BE).withOpacity(0.2),
                      ),
                      child: Slider(
                        value: progress.clamp(0.0, 1.0),
                        onChanged: (v) {
                          final target = Duration(
                            seconds: (v * _duration.inSeconds).round(),
                          );
                          if (mounted) setState(() => _position = target);
                        },
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(_fmt(_position),
                              style: AppTypography.caption
                                  .copyWith(color: AppColors.textMuted)),
                          Text(_fmt(_duration),
                              style: AppTypography.caption
                                  .copyWith(color: AppColors.textMuted)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Controls
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    icon: const Icon(Icons.replay_10_rounded, size: 36),
                    color: AppColors.textMuted,
                    onPressed: () => _skip(-15),
                  ),
                  const SizedBox(width: 24),
                  GestureDetector(
                    onTap: _togglePlay,
                    child: Container(
                      width: 72,
                      height: 72,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: const Color(0xFF7FB7BE),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF7FB7BE).withOpacity(0.4),
                            blurRadius: 16,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Icon(
                        _playing
                            ? Icons.pause_rounded
                            : Icons.play_arrow_rounded,
                        size: 36,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(width: 24),
                  IconButton(
                    icon: const Icon(Icons.forward_10_rounded, size: 36),
                    color: AppColors.textMuted,
                    onPressed: () => _skip(15),
                  ),
                ],
              ),

              const Spacer(),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
