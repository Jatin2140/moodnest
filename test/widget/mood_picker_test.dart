import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:moodnest/core/theme/app_colors.dart';
import 'package:moodnest/features/mood/widgets/mood_picker.dart';

Widget _wrap(Widget child) => MaterialApp(
      home: Scaffold(body: Center(child: child)),
    );

void main() {
  setUpAll(() => GoogleFonts.config.allowRuntimeFetching = false);

  group('MoodPicker', () {
    testWidgets('renders 5 mood nodes', (tester) async {
      await tester.pumpWidget(_wrap(
        MoodPicker(selected: null, onSelect: (_) {}),
      ));
      await tester.pump(Duration.zero); // drain flutter_animate init timers

      for (final emoji in MoodPalette.emoji.values) {
        expect(find.text(emoji), findsOneWidget);
      }
    });

    testWidgets('onSelect fires with correct MoodType on tap', (tester) async {
      MoodType? got;
      await tester.pumpWidget(_wrap(
        MoodPicker(selected: null, onSelect: (m) => got = m),
      ));
      await tester.pump(Duration.zero);

      final joyfulEmoji = MoodPalette.emoji[MoodType.joyful]!;
      await tester.tap(find.text(joyfulEmoji));
      await tester.pump();

      expect(got, MoodType.joyful);
    });

    testWidgets('selected node is visually distinct (larger)', (tester) async {
      await tester.pumpWidget(_wrap(
        MoodPicker(selected: MoodType.calm, onSelect: (_) {}),
      ));
      await tester.pump(Duration.zero);
      // Let AnimatedContainer settle its duration
      await tester.pump(const Duration(milliseconds: 250));

      final containers = tester.widgetList<AnimatedContainer>(
        find.byType(AnimatedContainer),
      ).toList();

      expect(
        containers.any((c) => c.constraints?.maxWidth == 64),
        isTrue,
      );
    });
  });
}
