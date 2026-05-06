class MeditationModel {
  final String id;
  final String title;
  final String description;
  final String category; // sleep, focus, reset, body_scan
  final int durationSeconds;
  final String audioAsset;
  final List<String> tags;
  final Map<String, double> moodFit; // mood name -> 0..1
  final double intensity; // 0..1
  final List<String> idealTimeBands; // morning/afternoon/evening/night

  const MeditationModel({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.durationSeconds,
    required this.audioAsset,
    required this.tags,
    required this.moodFit,
    required this.intensity,
    required this.idealTimeBands,
  });

  factory MeditationModel.fromJson(Map<String, dynamic> j) => MeditationModel(
        id: j['id'] as String,
        title: j['title'] as String,
        description: j['description'] as String,
        category: j['category'] as String,
        durationSeconds: j['durationSeconds'] as int,
        audioAsset: j['audioAsset'] as String,
        tags: List<String>.from(j['tags'] ?? []),
        moodFit: Map<String, double>.from(
            (j['moodFit'] as Map).map((k, v) => MapEntry(k, (v as num).toDouble()))),
        intensity: (j['intensity'] as num).toDouble(),
        idealTimeBands: List<String>.from(j['idealTimeBands'] ?? []),
      );

  String get durationLabel {
    final m = durationSeconds ~/ 60;
    final s = durationSeconds % 60;
    if (s == 0) return '${m}min';
    return '${m}m ${s}s';
  }
}
