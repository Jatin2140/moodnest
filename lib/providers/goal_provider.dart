import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import '../core/utils/result.dart';
import '../data/models/goal.dart';
import '../data/repositories/goal_repository.dart';

class GoalProvider extends ChangeNotifier {
  final GoalRepository _repo;
  final String uid;

  List<Goal> _goals = [];
  bool _loading = false;
  String? _justCompletedGoalId;

  GoalProvider({required this.uid, GoalRepository? repo})
      : _repo = repo ?? GoalRepository() {
    load();
  }

  List<Goal> get goals => _goals;
  List<Goal> get activeGoals => _goals.where((g) => g.isActive).toList();
  bool get isLoading => _loading;
  String? get justCompletedGoalId => _justCompletedGoalId;

  Future<void> load() async {
    _loading = true;
    notifyListeners();
    _goals = await _repo.getGoals(uid);
    _loading = false;
    _resetWeeklyProgressIfNeeded();
    notifyListeners();
  }

  Future<bool> addGoal({
    required String title,
    required GoalCategory category,
    required int targetPerWeek,
  }) async {
    if (activeGoals.length >= 5) return false;
    final goal = Goal(
      id: const Uuid().v4(),
      userId: uid,
      title: title,
      categoryIndex: category.index,
      targetPerWeek: targetPerWeek,
      createdAt: DateTime.now(),
      weekStartDate: _currentWeekStart(),
    );
    final result = await _repo.addGoal(goal);
    if (result.isOk) {
      _goals.insert(0, goal);
      notifyListeners();
    }
    return result.isOk;
  }

  Future<void> recordProgress(GoalCategory category) async {
    _justCompletedGoalId = null;
    for (final goal in activeGoals) {
      if (goal.category == category && !goal.isCompleted) {
        await _repo.incrementProgress(uid, goal.id);
        if (goal.isCompleted) {
          _justCompletedGoalId = goal.id;
        }
      }
    }
    notifyListeners();
  }

  Future<void> archiveGoal(String goalId) async {
    await _repo.archiveGoal(uid, goalId);
    final idx = _goals.indexWhere((g) => g.id == goalId);
    if (idx != -1) {
      _goals[idx].archivedAt = DateTime.now();
      notifyListeners();
    }
  }

  void clearJustCompleted() {
    _justCompletedGoalId = null;
  }

  DateTime _currentWeekStart() {
    final now = DateTime.now();
    return now.subtract(Duration(days: now.weekday - 1));
  }

  void _resetWeeklyProgressIfNeeded() {
    final weekStart = _currentWeekStart();
    for (final goal in _goals) {
      if (goal.weekStartDate == null ||
          goal.weekStartDate!.isBefore(weekStart)) {
        goal.currentWeekProgress = 0;
        goal.weekStartDate = weekStart;
        goal.save();
        _repo.updateGoal(goal);
      }
    }
  }
}
