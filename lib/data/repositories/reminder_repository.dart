import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:hive/hive.dart';
import 'package:timezone/timezone.dart' as tz;
import '../models/reminder.dart';
import '../../core/utils/result.dart';

class ReminderRepository {
  final FirebaseFirestore _db;
  final FlutterLocalNotificationsPlugin _notif;
  static const _boxName = 'reminders';

  ReminderRepository({
    FirebaseFirestore? db,
    FlutterLocalNotificationsPlugin? notif,
  })  : _db = db ?? FirebaseFirestore.instance,
        _notif = notif ?? FlutterLocalNotificationsPlugin();

  Box<Reminder> get _box => Hive.box<Reminder>(_boxName);

  CollectionReference<Map<String, dynamic>> _col(String uid) =>
      _db.collection('users').doc(uid).collection('reminders');

  Future<Result<void>> addReminder(Reminder reminder) async {
    _box.put(reminder.id, reminder);
    try {
      await _col(reminder.userId).doc(reminder.id).set(reminder.toMap());
    } catch (_) {}
    if (reminder.enabled) await _scheduleNotification(reminder);
    return const Ok(null);
  }

  Future<Result<void>> updateReminder(Reminder reminder) async {
    _box.put(reminder.id, reminder);
    try {
      await _col(reminder.userId).doc(reminder.id).update(reminder.toMap());
    } catch (_) {}
    await _cancelNotification(reminder.id);
    if (reminder.enabled) await _scheduleNotification(reminder);
    return const Ok(null);
  }

  Future<Result<void>> deleteReminder(String uid, String reminderId) async {
    _box.delete(reminderId);
    await _cancelNotification(reminderId);
    try {
      await _col(uid).doc(reminderId).delete();
    } catch (_) {}
    return const Ok(null);
  }

  Future<List<Reminder>> getReminders(String uid) async {
    try {
      final snap = await _col(uid).get();
      final remote =
          snap.docs.map((d) => Reminder.fromMap(d.data(), uid)).toList();
      for (final r in remote) {
        _box.put(r.id, r);
      }
      return remote;
    } catch (_) {
      return _box.values.where((r) => r.userId == uid).toList();
    }
  }

  Future<void> _scheduleNotification(Reminder reminder) async {
    final parts = reminder.time.split(':');
    final hour = int.parse(parts[0]);
    final minute = int.parse(parts[1]);

    final androidDetails = AndroidNotificationDetails(
      'moodnest_reminders',
      'MoodNest Reminders',
      channelDescription: 'Gentle reminders to check in with yourself',
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
    );

    final details = NotificationDetails(android: androidDetails);
    final body = switch (reminder.type) {
      ReminderType.mood => 'How are you feeling right now?',
      ReminderType.meditate => 'Time for a moment of calm.',
      ReminderType.journal => 'A few words can change your day.',
    };

    for (final day in reminder.daysOfWeek) {
      final id = _notifId(reminder.id, day);
      final scheduledDate = _nextWeekday(day, hour, minute);
      await _notif.zonedSchedule(
        id,
        reminder.label,
        body,
        scheduledDate,
        details,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
      );
    }
  }

  Future<void> _cancelNotification(String reminderId) async {
    for (int day = 1; day <= 7; day++) {
      await _notif.cancel(_notifId(reminderId, day));
    }
  }

  int _notifId(String reminderId, int day) =>
      (reminderId.hashCode.abs() % 10000) * 10 + day;

  tz.TZDateTime _nextWeekday(int weekday, int hour, int minute) {
    var now = tz.TZDateTime.now(tz.local);
    var candidate = tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minute);
    while (candidate.weekday != weekday || candidate.isBefore(now)) {
      candidate = candidate.add(const Duration(days: 1));
    }
    return candidate;
  }

  static String get boxName => _boxName;
}
