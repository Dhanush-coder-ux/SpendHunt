import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:finpilot_ai/app/theme/app_theme.dart';
import 'package:finpilot_ai/core/models/ai_message.dart';
import 'package:finpilot_ai/core/providers/ai_assistant_provider.dart';
import 'package:finpilot_ai/shared/widgets/app_bottom_navigation.dart';
import 'package:finpilot_ai/shared/widgets/spendhunt_ai_orb.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Native SpendHuntAIOrb Tests', () {
    testWidgets('SpendHuntAIOrb renders cleanly in idle state without external assets', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            theme: AppTheme.lightTheme(),
            home: const Scaffold(
              body: Center(
                child: SpendHuntAIOrb(size: 36, state: SpendHuntAIState.idle),
              ),
            ),
          ),
        ),
      );
      await tester.pump();
      expect(find.byType(SpendHuntAIOrb), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('SpendHuntAIOrb renders across all 5 states', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            theme: AppTheme.lightTheme(),
            home: const Scaffold(
              body: Column(
                children: [
                  SpendHuntAIOrb(size: 28, state: SpendHuntAIState.idle),
                  SpendHuntAIOrb(size: 28, state: SpendHuntAIState.active),
                  SpendHuntAIOrb(size: 28, state: SpendHuntAIState.thinking),
                  SpendHuntAIOrb(size: 28, state: SpendHuntAIState.response),
                  SpendHuntAIOrb(size: 28, state: SpendHuntAIState.error),
                ],
              ),
            ),
          ),
        ),
      );
      await tester.pump();
      expect(find.byType(SpendHuntAIOrb), findsNWidgets(5));
      expect(tester.takeException(), isNull);
    });

    testWidgets('AppBottomNavigation integrates SpendHuntAIOrb with label "SpendHunt AI"', (WidgetTester tester) async {
      int tappedIndex = -1;
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            theme: AppTheme.lightTheme(),
            home: Scaffold(
              bottomNavigationBar: AppBottomNavigation(
                currentIndex: 0,
                onTap: (index) => tappedIndex = index,
              ),
            ),
          ),
        ),
      );
      await tester.pump();

      expect(find.text('SpendHunt AI'), findsOneWidget);
      expect(find.byType(SpendHuntAIOrb), findsOneWidget);

      // Tap SpendHunt AI navigation item (index 3)
      await tester.tap(find.text('SpendHunt AI'));
      await tester.pump(const Duration(milliseconds: 300));
      expect(tappedIndex, equals(3));
    });

    test('AIAssistantNotifier connects states to AI request lifecycle', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier = container.read(aiAssistantProvider.notifier);
      expect(container.read(aiAssistantProvider).aiState, equals(SpendHuntAIState.idle));

      // Trigger active tap
      notifier.triggerActive();
      expect(container.read(aiAssistantProvider).aiState, equals(SpendHuntAIState.active));

      // Sending message sets state to THINKING
      final messageFuture = notifier.sendMessage('What are my top expenses?');
      expect(container.read(aiAssistantProvider).aiState, equals(SpendHuntAIState.thinking));
      expect(container.read(aiAssistantProvider).isTyping, isTrue);

      await messageFuture;
      // On response completion, state is RESPONSE
      expect(container.read(aiAssistantProvider).aiState, equals(SpendHuntAIState.response));
      expect(container.read(aiAssistantProvider).isTyping, isFalse);
      expect(container.read(aiAssistantProvider).messages.last.sender, equals(MessageSender.assistant));
    });
  });
}

