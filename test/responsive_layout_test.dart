import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:finpilot_ai/app/theme/app_theme.dart';
import 'package:finpilot_ai/features/onboarding/screens/financial_setup_screen.dart';
import 'package:finpilot_ai/features/savings/screens/savings_goals_screen.dart';
import 'package:finpilot_ai/features/loans/screens/loans_screen.dart';
import 'package:finpilot_ai/features/settings/screens/settings_screen.dart';
import 'package:finpilot_ai/features/receipt_scanner/screens/receipt_scanner_screen.dart';
import 'package:finpilot_ai/features/dashboard/screens/dashboard_screen.dart';
import 'package:finpilot_ai/features/transactions/screens/transactions_screen.dart';
import 'package:finpilot_ai/features/budgets/screens/budgets_overview_screen.dart';
import 'package:finpilot_ai/features/accounts/screens/accounts_overview_screen.dart';
import 'package:finpilot_ai/features/subscriptions/screens/subscriptions_screen.dart';
import 'package:finpilot_ai/features/investments/screens/investments_screen.dart';
import 'package:finpilot_ai/features/reports/screens/reports_overview_screen.dart';
import 'package:finpilot_ai/features/ai_assistant/screens/financial_health_screen.dart';
import 'package:finpilot_ai/features/ai_assistant/screens/ai_spending_analysis_screen.dart';
import 'package:finpilot_ai/features/ai_assistant/screens/ai_forecast_screen.dart';

Widget _createTestScreen(Widget screen, {required double width, required double height}) {
  return ProviderScope(
    child: MaterialApp(
      theme: AppTheme.lightTheme(),
      home: MediaQuery(
        data: MediaQueryData(
          size: Size(width, height),
          devicePixelRatio: 3.0,
          padding: const EdgeInsets.only(top: 44, bottom: 34),
        ),
        child: SizedBox(
          width: width,
          height: height,
          child: screen,
        ),
      ),
    ),
  );
}

void main() {
  const narrowWidth = 360.0;
  const screenHeight = 780.0;

  group('Responsive Layout Tests - No RenderFlex Overflows on 360px Screen', () {
    testWidgets('FinancialSetupScreen renders with zero overflow', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(narrowWidth * 3, screenHeight * 3);
      tester.view.devicePixelRatio = 3.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        _createTestScreen(const FinancialSetupScreen(), width: narrowWidth, height: screenHeight),
      );
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(find.byType(FinancialSetupScreen), findsOneWidget);
    });

    testWidgets('SavingsGoalsScreen renders with zero overflow', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(narrowWidth * 3, screenHeight * 3);
      tester.view.devicePixelRatio = 3.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        _createTestScreen(const SavingsGoalsScreen(), width: narrowWidth, height: screenHeight),
      );
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(find.byType(SavingsGoalsScreen), findsOneWidget);
    });

    testWidgets('LoansScreen renders with zero overflow', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(narrowWidth * 3, screenHeight * 3);
      tester.view.devicePixelRatio = 3.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        _createTestScreen(const LoansScreen(), width: narrowWidth, height: screenHeight),
      );
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(find.byType(LoansScreen), findsOneWidget);
    });

    testWidgets('SettingsScreen renders with zero overflow', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(narrowWidth * 3, screenHeight * 3);
      tester.view.devicePixelRatio = 3.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        _createTestScreen(const SettingsScreen(), width: narrowWidth, height: screenHeight),
      );
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(find.byType(SettingsScreen), findsOneWidget);
    });

    testWidgets('ReceiptScannerScreen renders with zero overflow', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(narrowWidth * 3, screenHeight * 3);
      tester.view.devicePixelRatio = 3.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        _createTestScreen(const ReceiptScannerScreen(), width: narrowWidth, height: screenHeight),
      );
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(find.byType(ReceiptScannerScreen), findsOneWidget);
    });

    testWidgets('DashboardScreen renders with zero overflow', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(narrowWidth * 3, screenHeight * 3);
      tester.view.devicePixelRatio = 3.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        _createTestScreen(const DashboardScreen(), width: narrowWidth, height: screenHeight),
      );
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(find.byType(DashboardScreen), findsOneWidget);
    });

    testWidgets('TransactionsScreen renders with zero overflow', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(narrowWidth * 3, screenHeight * 3);
      tester.view.devicePixelRatio = 3.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        _createTestScreen(const TransactionsScreen(), width: narrowWidth, height: screenHeight),
      );
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(find.byType(TransactionsScreen), findsOneWidget);
    });

    testWidgets('BudgetsOverviewScreen renders with zero overflow', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(narrowWidth * 3, screenHeight * 3);
      tester.view.devicePixelRatio = 3.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        _createTestScreen(const BudgetsOverviewScreen(), width: narrowWidth, height: screenHeight),
      );
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(find.byType(BudgetsOverviewScreen), findsOneWidget);
    });

    testWidgets('AccountsOverviewScreen renders with zero overflow', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(narrowWidth * 3, screenHeight * 3);
      tester.view.devicePixelRatio = 3.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        _createTestScreen(const AccountsOverviewScreen(), width: narrowWidth, height: screenHeight),
      );
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(find.byType(AccountsOverviewScreen), findsOneWidget);
    });

    testWidgets('SubscriptionsScreen renders with zero overflow', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(narrowWidth * 3, screenHeight * 3);
      tester.view.devicePixelRatio = 3.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        _createTestScreen(const SubscriptionsScreen(), width: narrowWidth, height: screenHeight),
      );
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(find.byType(SubscriptionsScreen), findsOneWidget);
    });

    testWidgets('InvestmentsScreen renders with zero overflow', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(narrowWidth * 3, screenHeight * 3);
      tester.view.devicePixelRatio = 3.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        _createTestScreen(const InvestmentsScreen(), width: narrowWidth, height: screenHeight),
      );
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(find.byType(InvestmentsScreen), findsOneWidget);
    });

    testWidgets('ReportsOverviewScreen renders with zero overflow', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(narrowWidth * 3, screenHeight * 3);
      tester.view.devicePixelRatio = 3.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        _createTestScreen(const ReportsOverviewScreen(), width: narrowWidth, height: screenHeight),
      );
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(find.byType(ReportsOverviewScreen), findsOneWidget);
    });

    testWidgets('FinancialHealthScreen renders with zero overflow', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(narrowWidth * 3, screenHeight * 3);
      tester.view.devicePixelRatio = 3.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        _createTestScreen(const FinancialHealthScreen(), width: narrowWidth, height: screenHeight),
      );
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(find.byType(FinancialHealthScreen), findsOneWidget);
    });

    testWidgets('AISpendingAnalysisScreen renders with zero overflow', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(narrowWidth * 3, screenHeight * 3);
      tester.view.devicePixelRatio = 3.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        _createTestScreen(const AISpendingAnalysisScreen(), width: narrowWidth, height: screenHeight),
      );
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(find.byType(AISpendingAnalysisScreen), findsOneWidget);
    });

    testWidgets('AIForecastScreen renders with zero overflow', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(narrowWidth * 3, screenHeight * 3);
      tester.view.devicePixelRatio = 3.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        _createTestScreen(const AIForecastScreen(), width: narrowWidth, height: screenHeight),
      );
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(find.byType(AIForecastScreen), findsOneWidget);
    });
  });
}
