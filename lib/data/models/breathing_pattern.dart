class BreathingPhase {
  final String label;
  final int seconds;
  final bool isHold;

  const BreathingPhase({
    required this.label,
    required this.seconds,
    this.isHold = false,
  });
}

class BreathingPattern {
  final String id;
  final String name;
  final String description;
  final List<BreathingPhase> phases;
  final List<String> tags;
  final Map<String, double> moodFit;
  final double intensity;
  final List<String> idealTimeBands;
  final int recommendedCycles;

  const BreathingPattern({
    required this.id,
    required this.name,
    required this.description,
    required this.phases,
    required this.tags,
    required this.moodFit,
    required this.intensity,
    required this.idealTimeBands,
    required this.recommendedCycles,
  });

  int get cycleDurationSeconds =>
      phases.fold(0, (sum, p) => sum + p.seconds);

  String get patternLabel =>
      phases.map((p) => p.seconds.toString()).join('-');
}
