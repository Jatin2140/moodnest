import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import '../core/utils/result.dart';
import '../core/theme/app_colors.dart';
import '../data/models/journal_entry.dart';
import '../data/repositories/journal_repository.dart';

class JournalProvider extends ChangeNotifier {
  final JournalRepository _repo;
  final String uid;

  List<JournalEntry> _entries = [];
  bool _loading = false;

  JournalProvider({required this.uid, JournalRepository? repo})
      : _repo = repo ?? JournalRepository() {
    load();
  }

  List<JournalEntry> get entries => _entries;
  bool get isLoading => _loading;

  Future<void> load() async {
    _loading = true;
    _entries = _repo.getCachedEntries(uid);
    notifyListeners();
    final remote = await _repo.getEntries(uid);
    _entries = remote;
    _loading = false;
    notifyListeners();
  }

  Future<bool> addEntry({
    required String body,
    String? promptId,
    MoodType? mood,
  }) async {
    final wordCount = body.trim().split(RegExp(r'\s+')).length;
    final entry = JournalEntry(
      id: const Uuid().v4(),
      userId: uid,
      promptId: promptId,
      bodyMarkdown: body,
      moodIndex: mood?.index,
      wordCount: wordCount,
      createdAt: DateTime.now(),
    );
    final result = await _repo.addEntry(entry);
    if (result.isOk) {
      _entries.insert(0, entry);
      notifyListeners();
    }
    return result.isOk;
  }

  Future<bool> updateEntry({
    required JournalEntry entry,
    required String body,
    String? promptId,
    MoodType? mood,
  }) async {
    final wordCount = body.trim().split(RegExp(r'\s+')).length;
    final updatedEntry = entry.copyWith(
      bodyMarkdown: body,
      promptId: promptId,
      moodIndex: mood?.index,
      wordCount: wordCount,
    );
    final result = await _repo.updateEntry(updatedEntry);
    if (result.isOk) {
      final index = _entries.indexWhere((e) => e.id == entry.id);
      if (index != -1) {
        _entries[index] = updatedEntry;
        notifyListeners();
      }
    }
    return result.isOk;
  }

  Future<bool> deleteEntry(String entryId) async {
    final result = await _repo.deleteEntry(uid, entryId);
    if (result.isOk) {
      _entries.removeWhere((e) => e.id == entryId);
      notifyListeners();
    }
    return result.isOk;
  }

  String exportText() => _repo.exportAsText(_entries);
  Future<void> syncPending() => _repo.syncPending(uid);
}
