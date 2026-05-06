import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hive/hive.dart';
import '../models/journal_entry.dart';
import '../../core/utils/result.dart';

class JournalRepository {
  final FirebaseFirestore _db;
  static const _boxName = 'journals';

  JournalRepository({FirebaseFirestore? db})
      : _db = db ?? FirebaseFirestore.instance;

  Box<JournalEntry> get _box => Hive.box<JournalEntry>(_boxName);

  CollectionReference<Map<String, dynamic>> _col(String uid) =>
      _db.collection('users').doc(uid).collection('journals');

  Future<Result<void>> addEntry(JournalEntry entry) async {
    await _box.put(entry.id, entry);
    try {
      await _col(entry.userId).doc(entry.id).set(entry.toMap());
      entry.pendingSync = false;
      await _box.put(entry.id, entry);
      return const Ok(null);
    } catch (_) {
      entry.pendingSync = true;
      await _box.put(entry.id, entry);
      return const Ok(null);
    }
  }

  Future<Result<void>> updateEntry(JournalEntry entry) async {
    await _box.put(entry.id, entry);
    try {
      await _col(entry.userId).doc(entry.id).set(entry.toMap(), SetOptions(merge: true));
      entry.pendingSync = false;
      await _box.put(entry.id, entry);
      return const Ok(null);
    } catch (_) {
      entry.pendingSync = true;
      await _box.put(entry.id, entry);
      return const Ok(null);
    }
  }

  Future<Result<void>> deleteEntry(String uid, String entryId) async {
    _box.delete(entryId);
    try {
      await _col(uid).doc(entryId).delete();
      return const Ok(null);
    } catch (_) {
      // In a more robust system, we would mark it for deletion sync
      return const Ok(null);
    }
  }

  Future<List<JournalEntry>> getEntries(String uid) async {
    try {
      final snap = await _col(uid)
          .orderBy('createdAt', descending: true)
          .limit(50)
          .get();
      final remote =
          snap.docs.map((d) => JournalEntry.fromMap(d.data(), uid)).toList();
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

  List<JournalEntry> getCachedEntries(String uid) {
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

  String exportAsText(List<JournalEntry> entries) {
    final buf = StringBuffer('MoodNest Journal Export\n');
    buf.writeln('=' * 40);
    for (final e in entries) {
      buf.writeln('\n${e.createdAt.toLocal().toString().split('.')[0]}');
      buf.writeln('-' * 20);
      buf.writeln(e.bodyMarkdown);
    }
    return buf.toString();
  }

  static String get boxName => _boxName;
}
