import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import '../core/utils/result.dart';
import '../data/models/reminder.dart';
import '../data/repositories/reminder_repository.dart';

class ReminderProvider extends ChangeNotifier {
  final ReminderRepository _repo;
  final String uid;

  List<Reminder> _reminders = [];
  bool _loading = false;

  ReminderProvider({required this.uid, ReminderRepository? repo})
      : _repo = repo ?? ReminderRepository() {
    load();
  }

  List<Reminder> get reminders => _reminders;
  bool get isLoading => _loading;

  Future<void> load() async {
    _loading = true;
    notifyListeners();
    _reminders = await _repo.getReminders(uid);
    _loading = false;
    notifyListeners();
  }

  Future<bool> addReminder({
    required ReminderType type,
    required String time,
    required List<int> daysOfWeek,
  }) async {
    final reminder = Reminder(
      id: const Uuid().v4(),
      userId: uid,
      typeIndex: type.index,
      time: time,
      daysOfWeek: daysOfWeek,
    );
    final result = await _repo.addReminder(reminder);
    if (result.isOk) {
      _reminders.add(reminder);
      notifyListeners();
    }
    return result.isOk;
  }

  Future<void> toggleReminder(String reminderId) async {
    final idx = _reminders.indexWhere((r) => r.id == reminderId);
    if (idx == -1) return;
    _reminders[idx].enabled = !_reminders[idx].enabled;
    await _repo.updateReminder(_reminders[idx]);
    notifyListeners();
  }

  Future<void> deleteReminder(String reminderId) async {
    await _repo.deleteReminder(uid, reminderId);
    _reminders.removeWhere((r) => r.id == reminderId);
    notifyListeners();
  }
}
