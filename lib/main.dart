import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:firebase_core/firebase_core.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

import 'firebase_options.dart';
import 'data/models/mood_entry.dart';
import 'data/models/journal_entry.dart';
import 'data/models/goal.dart';
import 'data/models/reminder.dart';
import 'data/repositories/mood_repository.dart';
import 'data/repositories/journal_repository.dart';
import 'data/repositories/goal_repository.dart';
import 'data/repositories/reminder_repository.dart';
import 'app.dart';

final FlutterLocalNotificationsPlugin notificationsPlugin =
    FlutterLocalNotificationsPlugin();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Hive
  await Hive.initFlutter();
  Hive.registerAdapter(MoodEntryAdapter());
  Hive.registerAdapter(JournalEntryAdapter());
  Hive.registerAdapter(GoalAdapter());
  Hive.registerAdapter(ReminderAdapter());

  await Future.wait([
    Hive.openBox<MoodEntry>(MoodRepository.boxName),
    Hive.openBox<JournalEntry>(JournalRepository.boxName),
    Hive.openBox<Goal>(GoalRepository.boxName),
    Hive.openBox<Reminder>(ReminderRepository.boxName),
  ]);

  // Timezones (for local notifications)
  tz.initializeTimeZones();
  try {
    final localTz = DateTime.now().timeZoneName;
    tz.setLocalLocation(tz.getLocation(localTz));
  } catch (_) {
    tz.setLocalLocation(tz.UTC);
  }

  // Local notifications (not supported on web)
  if (!kIsWeb) {
    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosInit = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );
    await notificationsPlugin.initialize(
      const InitializationSettings(android: androidInit, iOS: iosInit),
    );
  }

  runApp(const MoodNestApp());
}
