import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/meditation.dart';
import '../models/breathing_pattern.dart';

class ContentRepository {
  List<MeditationModel>? _meditations;
  List<BreathingPattern>? _breathingPatterns;
  List<Map<String, dynamic>>? _prompts;

  static final ContentRepository _instance = ContentRepository._();
  factory ContentRepository() => _instance;
  ContentRepository._();

  Future<List<MeditationModel>> getMeditations() async {
    if (_meditations != null) return _meditations!;
    final raw = await rootBundle.loadString('assets/data/meditations.json');
    final list = jsonDecode(raw) as List;
    _meditations = list.map((j) => MeditationModel.fromJson(j as Map<String, dynamic>)).toList();
    return _meditations!;
  }

  Future<List<BreathingPattern>> getBreathingPatterns() async {
    if (_breathingPatterns != null) return _breathingPatterns!;
    final raw = await rootBundle.loadString('assets/data/breathing_patterns.json');
    final list = jsonDecode(raw) as List;
    _breathingPatterns = list.map((j) => _parsePattern(j as Map<String, dynamic>)).toList();
    return _breathingPatterns!;
  }

  Future<List<Map<String, dynamic>>> getJournalPrompts() async {
    if (_prompts != null) return _prompts!;
    final raw = await rootBundle.loadString('assets/data/journal_prompts.json');
    _prompts = List<Map<String, dynamic>>.from(jsonDecode(raw) as List);
    return _prompts!;
  }

  Future<List<Map<String, dynamic>>> getPromptsForMood(String moodName) async {
    final all = await getJournalPrompts();
    final filtered = all.where((p) {
      final moods = List<String>.from(p['moods'] as List? ?? []);
      return moods.contains(moodName) || moods.isEmpty;
    }).toList();
    filtered.shuffle();
    return filtered.take(5).toList();
  }

  BreathingPattern _parsePattern(Map<String, dynamic> j) {
    final phases = (j['phases'] as List)
        .map((p) => BreathingPhase(
              label: p['label'] as String,
              seconds: p['seconds'] as int,
              isHold: (p['isHold'] as bool?) ?? false,
            ))
        .toList();

    return BreathingPattern(
      id: j['id'] as String,
      name: j['name'] as String,
      description: j['description'] as String,
      phases: phases,
      tags: List<String>.from(j['tags'] ?? []),
      moodFit: Map<String, double>.from(
          (j['moodFit'] as Map).map((k, v) => MapEntry(k, (v as num).toDouble()))),
      intensity: (j['intensity'] as num).toDouble(),
      idealTimeBands: List<String>.from(j['idealTimeBands'] ?? []),
      recommendedCycles: (j['recommendedCycles'] as int?) ?? 6,
    );
  }
}
