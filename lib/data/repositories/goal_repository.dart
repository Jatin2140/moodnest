import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hive/hive.dart';
import '../models/goal.dart';
import '../../core/utils/result.dart';

class GoalRepository {
  final FirebaseFirestore _db;
  static const _boxName = 'goals';

  GoalRepository({FirebaseFirestore? db})
      : _db = db ?? FirebaseFirestore.instance;

  Box<Goal> get _box => Hive.box<Goal>(_boxName);

  CollectionReference<Map<String, dynamic>> _col(String uid) =>
      _db.collection('users').doc(uid).collection('goals');

  Future<Result<void>> addGoal(Goal goal) async {
    _box.put(goal.id, goal);
    try {
      await _col(goal.userId).doc(goal.id).set(goal.toMap());
      return const Ok(null);
    } catch (e) {
      return Err('Could not save goal. It\'s stored locally.');
    }
  }

  Future<Result<void>> updateGoal(Goal goal) async {
    _box.put(goal.id, goal);
    try {
      await _col(goal.userId).doc(goal.id).update(goal.toMap());
      return const Ok(null);
    } catch (e) {
      return Err('Could not sync goal update.');
    }
  }

  Future<Result<void>> incrementProgress(String uid, String goalId) async {
    final goal = _box.get(goalId);
    if (goal == null) return Err('Goal not found.');
    goal.currentWeekProgress++;
    goal.save();
    try {
      await _col(uid)
          .doc(goalId)
          .update({'currentWeekProgress': goal.currentWeekProgress});
      return const Ok(null);
    } catch (_) {
      return const Ok(null);
    }
  }

  Future<Result<void>> archiveGoal(String uid, String goalId) async {
    final goal = _box.get(goalId);
    if (goal == null) return Err('Goal not found.');
    goal.archivedAt = DateTime.now();
    goal.save();
    try {
      await _col(uid)
          .doc(goalId)
          .update({'archivedAt': goal.archivedAt!.toIso8601String()});
      return const Ok(null);
    } catch (_) {
      return const Ok(null);
    }
  }

  Future<List<Goal>> getGoals(String uid) async {
    try {
      final snap = await _col(uid).get();
      final remote = snap.docs.map((d) => Goal.fromMap(d.data(), uid)).toList();
      for (final g in remote) {
        _box.put(g.id, g);
      }
      return remote..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    } catch (_) {
      return _box.values
          .where((g) => g.userId == uid)
          .toList()
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    }
  }

  static String get boxName => _boxName;
}
