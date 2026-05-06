import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hive/hive.dart';
import '../models/mood_entry.dart';
import '../../core/utils/result.dart';

class MoodRepository {
  final FirebaseFirestore _db;
  static const _boxName = 'moods';

  MoodRepository({FirebaseFirestore? db})
      : _db = db ?? FirebaseFirestore.instance;

  Box<MoodEntry> get _box => Hive.box<MoodEntry>(_boxName);

  CollectionReference<Map<String, dynamic>> _col(String uid) =>
      _db.collection('users').doc(uid).collection('moods');

  Future<Result<void>> addMood(MoodEntry entry) async {
    await _box.put(entry.id, entry);
    try {
      await _col(entry.userId).doc(entry.id).set(entry.toMap());
      entry.pendingSync = false;
      await _box.put(entry.id, entry);
      return const Ok(null);
    } catch (_) {
      entry.pendingSync = true;
      await _box.put(entry.id, entry);
      return const Ok(null); // saved locally
    }
  }

  Future<List<MoodEntry>> getMoods(String uid) async {
    try {
      final snap = await _col(uid)
          .orderBy('createdAt', descending: true)
          .limit(90)
          .get();
      final remote = snap.docs
          .map((d) => MoodEntry.fromMap(d.data(), uid))
          .toList();
      for (final e in remote) {
        _box.put(e.id, e);
      }
      return remote;
    } catch (_) {
      return _box.values
          .where((e) => e.userId == uid)
          .toList()
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    }
  }

  List<MoodEntry> getCachedMoods(String uid) {
    return _box.values
        .where((e) => e.userId == uid)
        .toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  Future<void> syncPending(String uid) async {
    final pending =
        _box.values.where((e) => e.userId == uid && e.pendingSync).toList();
    for (final entry in pending) {
      try {
        await _col(uid).doc(entry.id).set(entry.toMap(), SetOptions(merge: true));
        entry.pendingSync = false;
        await _box.put(entry.id, entry);
      } catch (_) {}
    }
  }

  static String get boxName => _boxName;
}
