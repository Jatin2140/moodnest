// Integration test: sign up → onboarding → log first mood → dashboard shows recommendation slot.
// Run with: flutter test integration_test/app_flow_test.dart
//
// Requires a connected device/emulator and Firebase configured.
// In CI use the Firebase Test Lab emulator.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:moodnest/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Full sign-up → mood log → dashboard flow', (tester) async {
    app.main();
    await tester.pumpAndSettle(const Duration(seconds: 3));

    // Should land on Login screen
    expect(find.text('Welcome back'), findsOneWidget);

    // Navigate to Sign Up
    await tester.tap(find.text('Sign up'));
    await tester.pumpAndSettle();

    // Fill signup form
    final testEmail = 'test_${DateTime.now().millisecondsSinceEpoch}@moodnest.dev';
    await tester.enterText(find.byType(TextFormField).at(0), 'Tester');
    await tester.enterText(find.byType(TextFormField).at(1), testEmail);
    await tester.enterText(find.byType(TextFormField).at(2), 'Password123!');
    await tester.enterText(find.byType(TextFormField).at(3), 'Password123!');
    await tester.tap(find.text('Sign up').last);
    await tester.pumpAndSettle(const Duration(seconds: 4));

    // Should be on onboarding
    expect(find.text('Track how you feel'), findsOneWidget);

    // Page through onboarding
    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();

    // Last page: pick a mood (calm emoji)
    await tester.tap(find.text('😌'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Log your first mood'));
    await tester.pumpAndSettle(const Duration(seconds: 3));

    // Should be on Dashboard
    expect(find.text('MoodNest'), findsWidgets);
    expect(find.text('How are you feeling today?'), findsOneWidget);

    // Recommendation section should be visible (either recommendations or log-mood prompt)
    expect(
      find.byWidgetPredicate((w) =>
          w is Text && (w.data?.contains('Recommended') == true ||
              w.data?.contains('Log your mood first') == true)),
      findsWidgets,
    );
  });
}
