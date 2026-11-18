import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:finpilot_ai/app/theme/app_theme.dart';
import 'package:finpilot_ai/features/onboarding/screens/onboarding_screen.dart';
import 'package:finpilot_ai/features/onboarding/widgets/onboarding_illustration.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Widget buildTestableOnboarding({GoRouter? router}) {
    final effectiveRouter = router ??
        GoRouter(
          initialLocation: '/onboarding',
          routes: [
            GoRoute(
              path: '/onboarding',
              builder: (context, state) => const OnboardingScreen(),
            ),
            GoRoute(
              path: '/sign-in',
              builder: (context, state) => const Scaffold(body: Text('Sign In Screen')),
            ),
          ],
        );

    return MaterialApp.router(
      theme: AppTheme.lightTheme(),
      routerConfig: effectiveRouter,
    );
  }

  group('SpendHunt Onboarding Screen Tests', () {
    testWidgets('renders Screen 1 (AI Insights) with Lottie illustration and no old circular icon',
        (WidgetTester tester) async {
      await tester.pumpWidget(buildTestableOnboarding());
      await tester.pump();

      // Heading and description for Screen 1
      expect(find.text('Let AI help you make smarter decisions'), findsOneWidget);
      expect(
        find.text(
          'SpendHunt AI analyses your cash flow run-rate, highlights anomalous expenses, and provides predictive end-of-month forecasts.',
        ),
        findsOneWidget,
      );

      // Verify OnboardingIllustration is present
      expect(find.byType(OnboardingIllustration), findsOneWidget);
      final illustration = tester.widget<OnboardingIllustration>(
        find.byType(OnboardingIllustration).first,
      );
      expect(illustration.assetPath, equals('assets/animations/ai_insights.json'));
      expect(illustration.isActive, isTrue);

      // Verify button says Continue
      expect(find.text('Continue'), findsOneWidget);
      expect(find.text('Skip'), findsOneWidget);
    });

    testWidgets('navigates through all 3 screens and updates animations & button label',
        (WidgetTester tester) async {
      await tester.pumpWidget(buildTestableOnboarding());
      await tester.pump();

      // Screen 1: AI Insights
      expect(find.text('Let AI help you make smarter decisions'), findsOneWidget);
      expect(find.text('Continue'), findsOneWidget);

      // Tap Continue -> Screen 2: Financial Goals
      await tester.tap(find.text('Continue'));
      // Advance frames for PageView animation
      for (int i = 0; i < 5; i++) {
        await tester.pump(const Duration(milliseconds: 100));
      }

      expect(find.text('Manage your financial goals'), findsOneWidget);
      expect(
        find.text(
          'Set category spending budgets, track upcoming loans, monitor subscriptions, and watch your emergency fund grow progressively.',
        ),
        findsOneWidget,
      );
      expect(find.text('Continue'), findsOneWidget);

      // Tap Continue -> Screen 3: Understand Your Money
      await tester.tap(find.text('Continue'));
      for (int i = 0; i < 5; i++) {
        await tester.pump(const Duration(milliseconds: 100));
      }

      expect(find.text('Understand your money'), findsOneWidget);
      expect(
        find.text(
          'Consolidate every savings account, digital wallet, credit card and cash balance into one unified, calm, and private command center.',
        ),
        findsOneWidget,
      );

      // Final screen button says Get Started
      expect(find.text('Get Started'), findsOneWidget);

      // Tap Get Started -> navigates to Sign In
      await tester.tap(find.text('Get Started'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      expect(find.text('Sign In Screen'), findsOneWidget);
    });

    testWidgets('Skip button navigates directly to sign in', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestableOnboarding());
      await tester.pump();

      await tester.tap(find.text('Skip'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      expect(find.text('Sign In Screen'), findsOneWidget);
    });

    testWidgets('Responsive Layout - zero overflows on small 360x640 screen',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(360, 640);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(buildTestableOnboarding());
      await tester.pump();

      expect(tester.takeException(), isNull);
      expect(find.byType(OnboardingIllustration), findsOneWidget);
    });

    testWidgets('Responsive Layout - zero overflows on tablet 800x1280 screen',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(800, 1280);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(buildTestableOnboarding());
      await tester.pump();

      expect(tester.takeException(), isNull);
      expect(find.byType(OnboardingIllustration), findsOneWidget);
    });
  });
}
