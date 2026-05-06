import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import '../core/utils/result.dart';
import '../core/theme/app_colors.dart';
import '../data/models/mood_entry.dart';
import '../data/repositories/mood_repository.dart';

class MoodProvider extends ChangeNotifier {
  final MoodRepository _repo;
  final String uid;

  List<MoodEntry> _moods = [];
  bool _loading = false;
  String? _error;

  MoodProvider({required this.uid, MoodRepository? repo})
      : _repo = repo ?? MoodRepository() {
    load();
  }

  List<MoodEntry> get moods => _moods;
  bool get isLoading => _loading;
  String? get error => _error;

  MoodEntry? get todayMood {
    final today = DateTime.now();
    return _moods.where((m) {
      return m.createdAt.year == today.year &&
          m.createdAt.month == today.month &&
          m.createdAt.day == today.day;
    }).firstOrNull;
  }

  List<DateTime> get moodDates => _moods.map((m) => m.createdAt).toList();

  List<MoodEntry> get last7 {
    final cutoff = DateTime.now().subtract(const Duration(days: 7));
    return _moods.where((m) => m.createdAt.isAfter(cutoff)).toList();
  }

  Future<void> load() async {
    _loading = true;
    _error = null;
    _moods = _repo.getCachedMoods(uid);
    notifyListeners();
    final remote = await _repo.getMoods(uid);
    _moods = remote;
    _loading = false;
    notifyListeners();
  }

  Future<bool> logMood({
    required MoodType mood,
    String? note,
    List<String> tags = const [],
  }) async {
    final entry = MoodEntry(
      id: const Uuid().v4(),
      userId: uid,
      moodIndex: mood.index,
      valence: MoodPalette.valence[mood]!,
      note: note,
      tags: tags,
      createdAt: DateTime.now(),
    );

    final result = await _repo.addMood(entry);
    if (result.isOk) {
      _moods.insert(0, entry);
      notifyListeners();
    }
    return result.isOk;
  }

  Future<void> syncPending() => _repo.syncPending(uid);
}
