import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:finpilot_ai/widgets/spendhunt_intro_page.dart';
import 'package:finpilot_ai/widgets/money_fan_icon.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('SpendHuntIntroPage Tests', () {
    testWidgets('renders correctly with black background and transparent system overlay',
        (WidgetTester tester) async {
      bool finishedCalled = false;

      await tester.pumpWidget(
        MaterialApp(
          home: SpendHuntIntroPage(
            onFinished: () {
              finishedCalled = true;
            },
          ),
        ),
      );

      // Verify AnnotatedRegion<SystemUiOverlayStyle> is present with transparent bars
      final annotatedRegion = tester.widget<AnnotatedRegion<SystemUiOverlayStyle>>(
        find.byType(AnnotatedRegion<SystemUiOverlayStyle>),
      );
      expect(annotatedRegion.value.statusBarColor, equals(Colors.transparent));
      expect(annotatedRegion.value.systemNavigationBarColor, equals(Colors.transparent));

      // Verify Scaffold has black background
      final scaffold = tester.widget<Scaffold>(find.byType(Scaffold));
      expect(scaffold.backgroundColor, equals(Colors.black));

      // Verify MoneyFanIcon widget is rendered
      expect(find.byType(MoneyFanIcon), findsOneWidget);

      // Advance past the accidental touch grace period (600ms)
      await tester.pump(const Duration(milliseconds: 650));

      // Verify tapping triggers onFinished skip
      await tester.tap(find.byType(GestureDetector).first);
      await tester.pump();
      expect(finishedCalled, isTrue);
    });

    testWidgets('displays App name letters progressively', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: SpendHuntIntroPage(
            appName: 'SpendHunt',
            onFinished: () {},
          ),
        ),
      );

      expect(find.text('S'), findsOneWidget);
      expect(find.text('p'), findsOneWidget);
      expect(find.text('e'), findsOneWidget);
      expect(find.text('d'), findsOneWidget);
      expect(find.text('H'), findsOneWidget);
      expect(find.text('u'), findsOneWidget);
      expect(find.text('t'), findsOneWidget);
      // 'n' appears twice in 'SpendHunt' (Spe[n]dHu[n]t)
      expect(find.text('n'), findsNWidgets(2));
    });
  });
}
