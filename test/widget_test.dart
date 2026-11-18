import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:finpilot_ai/app/app.dart';
import 'package:finpilot_ai/widgets/spendhunt_intro_page.dart';

void main() {
  testWidgets('SpendHunt App launches and renders smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: SpendHuntApp(),
      ),
    );
    await tester.pump();
    expect(find.byType(SpendHuntApp), findsOneWidget);
    expect(find.byType(SpendHuntIntroPage), findsOneWidget);
  });
}


