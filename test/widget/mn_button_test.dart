import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:moodnest/widgets/mn_button.dart';

Widget _wrap(Widget child) => MaterialApp(
      home: Scaffold(body: Center(child: child)),
    );

void main() {
  setUpAll(() => GoogleFonts.config.allowRuntimeFetching = false);

  group('MnButton', () {
    testWidgets('renders label text', (tester) async {
      await tester.pumpWidget(_wrap(
        const MnButton(label: 'Press me'),
      ));
      await tester.pump(Duration.zero);
      expect(find.text('Press me'), findsOneWidget);
    });

    testWidgets('loading state shows spinner and disables tap', (tester) async {
      int taps = 0;
      await tester.pumpWidget(_wrap(
        MnButton(
          label: 'Submit',
          isLoading: true,
          onPressed: () => taps++,
        ),
      ));
      await tester.pump(Duration.zero);

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('Submit'), findsNothing);

      await tester.tap(find.byType(MnButton));
      await tester.pump();
      expect(taps, 0);
    });

    testWidgets('onPressed fires on tap', (tester) async {
      int taps = 0;
      await tester.pumpWidget(_wrap(
        MnButton(label: 'Tap', onPressed: () => taps++),
      ));
      await tester.pump(Duration.zero);
      await tester.tap(find.byType(MnButton));
      await tester.pump();
      expect(taps, 1);
    });

    testWidgets('secondary variant renders without gradient', (tester) async {
      await tester.pumpWidget(_wrap(
        const MnButton(
          label: 'Secondary',
          variant: MnButtonVariant.secondary,
        ),
      ));
      await tester.pump(Duration.zero);
      expect(find.text('Secondary'), findsOneWidget);

      final decorated = tester.widgetList<DecoratedBox>(find.byType(DecoratedBox));
      final hasGradient = decorated.any((d) {
        final dec = d.decoration;
        return dec is BoxDecoration && dec.gradient != null;
      });
      expect(hasGradient, isFalse);
    });
  });
}
