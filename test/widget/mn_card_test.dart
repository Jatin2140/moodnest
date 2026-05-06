import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:moodnest/widgets/mn_card.dart';
import 'package:moodnest/core/theme/app_colors.dart';

Widget _wrap(Widget child) => MaterialApp(
      home: Scaffold(body: Center(child: child)),
    );

void main() {
  setUpAll(() => GoogleFonts.config.allowRuntimeFetching = false);

  group('MnCard', () {
    testWidgets('renders child content', (tester) async {
      await tester.pumpWidget(_wrap(
        const MnCard(child: Text('Hello MoodNest')),
      ));
      await tester.pump(Duration.zero);

      expect(find.text('Hello MoodNest'), findsOneWidget);
    });

    testWidgets('onTap callback fires when tapped', (tester) async {
      int taps = 0;
      await tester.pumpWidget(_wrap(
        MnCard(
          onTap: () => taps++,
          child: const Text('Tappable'),
        ),
      ));
      await tester.pump(Duration.zero);

      await tester.tap(find.text('Tappable'));
      await tester.pump();
      expect(taps, 1);
    });

    testWidgets('applies correct border radius', (tester) async {
      await tester.pumpWidget(_wrap(
        const MnCard(
          borderRadius: 12,
          child: Text('Custom radius'),
        ),
      ));
      await tester.pump(Duration.zero);

      final ink = tester.widget<Ink>(find.byType(Ink));
      final decoration = ink.decoration as BoxDecoration;
      final radius = (decoration.borderRadius as BorderRadius).topLeft;
      expect(radius, const Radius.circular(12));
    });

    testWidgets('mood card applies soft background color', (tester) async {
      await tester.pumpWidget(_wrap(
        const MnCard(
          mood: MoodType.joyful,
          child: Text('Joyful card'),
        ),
      ));
      await tester.pump(Duration.zero);

      final ink = tester.widget<Ink>(find.byType(Ink));
      final decoration = ink.decoration as BoxDecoration;
      // In light mode, mood card should use the soft background color
      expect(decoration.color, isNotNull);
      expect(decoration.color, isNot(AppColors.surface));
    });
  });
}
