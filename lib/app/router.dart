import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../features/onboarding/screens/onboarding_screen.dart';
import '../features/onboarding/screens/financial_setup_screen.dart';
import '../features/authentication/screens/sign_in_screen.dart';
import '../features/authentication/screens/register_screen.dart';
import '../features/dashboard/screens/dashboard_screen.dart';
import '../features/transactions/screens/transactions_screen.dart';
import '../features/transactions/screens/add_transaction_screen.dart';
import '../features/transactions/screens/transaction_details_screen.dart';
import '../features/transactions/screens/categories_screen.dart';
import '../features/accounts/screens/accounts_overview_screen.dart';
import '../features/accounts/screens/account_details_screen.dart';
import '../features/accounts/screens/add_account_screen.dart';
import '../features/budgets/screens/budgets_overview_screen.dart';
import '../features/budgets/screens/create_budget_screen.dart';
import '../features/budgets/screens/budget_details_screen.dart';
import '../features/savings/screens/savings_goals_screen.dart';
import '../features/savings/screens/create_goal_screen.dart';
import '../features/savings/screens/goal_details_screen.dart';
import '../features/investments/screens/investments_screen.dart';
import '../features/investments/screens/add_investment_screen.dart';
import '../features/investments/screens/investment_details_screen.dart';
import '../features/loans/screens/loans_screen.dart';
import '../features/loans/screens/add_loan_screen.dart';
import '../features/loans/screens/loan_details_screen.dart';
import '../features/subscriptions/screens/subscriptions_screen.dart';
import '../features/subscriptions/screens/add_subscription_screen.dart';
import '../features/subscriptions/screens/subscription_details_screen.dart';
import '../features/ai_assistant/screens/ai_assistant_screen.dart';
import '../features/ai_assistant/screens/ai_spending_analysis_screen.dart';
import '../features/ai_assistant/screens/ai_forecast_screen.dart';
import '../features/ai_assistant/screens/financial_health_screen.dart';
import '../features/receipt_scanner/screens/receipt_scanner_screen.dart';
import '../features/reports/screens/reports_overview_screen.dart';
import '../features/reports/screens/detailed_reports_screen.dart';
import '../features/notifications/screens/notifications_screen.dart';
import '../features/profile/screens/user_profile_screen.dart';
import '../features/settings/screens/settings_screen.dart';
import '../shared/widgets/responsive_scaffold.dart';
import '../widgets/spendhunt_intro_page.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>();
final GlobalKey<NavigatorState> _shellNavigatorKey = GlobalKey<NavigatorState>();

final appRouter = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: '/intro',
  routes: [
    // App Launch Intro Screen
    GoRoute(
      path: '/intro',
      builder: (context, state) => SpendHuntIntroPage(
        onFinished: () {
          Navigator.of(context).pushReplacement(
            PageRouteBuilder(
              transitionDuration: const Duration(milliseconds: 500),
              pageBuilder: (context, animation, secondaryAnimation) =>
                  const OnboardingScreen(),
              transitionsBuilder:
                  (context, animation, secondaryAnimation, child) =>
                      FadeTransition(opacity: animation, child: child),
            ),
          );
        },
      ),
    ),
    GoRoute(
      path: '/splash',
      redirect: (context, state) => '/intro',
    ),
    // Onboarding & Auth
    GoRoute(
      path: '/onboarding',
      builder: (context, state) => const OnboardingScreen(),
    ),
    GoRoute(
      path: '/sign-in',
      builder: (context, state) => const SignInScreen(),
    ),
    GoRoute(
      path: '/register',
      builder: (context, state) => const RegisterScreen(),
    ),
    GoRoute(
      path: '/financial-setup',
      builder: (context, state) => const FinancialSetupScreen(),
    ),

    // Shell Route for Main Bottom Nav / Desktop Sidebar
    ShellRoute(
      navigatorKey: _shellNavigatorKey,
      builder: (context, state, child) {
        int currentIndex = 0;
        final loc = state.uri.toString();
        if (loc.startsWith('/transactions')) {
          currentIndex = 1;
        } else if (loc.startsWith('/budgets')) {
          currentIndex = 2;
        } else if (loc.startsWith('/ai')) {
          currentIndex = 3;
        } else if (loc.startsWith('/profile')) {
          currentIndex = 4;
        }
        return ResponsiveScaffold(
          currentIndex: currentIndex,
          child: child,
        );
      },
      routes: [
        GoRoute(
          path: '/dashboard',
          builder: (context, state) => const DashboardScreen(),
        ),
        GoRoute(
          path: '/transactions',
          builder: (context, state) => const TransactionsScreen(),
        ),
        GoRoute(
          path: '/budgets',
          builder: (context, state) => const BudgetsOverviewScreen(),
        ),
        GoRoute(
          path: '/ai',
          builder: (context, state) => const AIAssistantScreen(),
        ),
        GoRoute(
          path: '/profile',
          builder: (context, state) => const UserProfileScreen(),
        ),
      ],
    ),

    // Transactions Subroutes
    GoRoute(
      path: '/transactions/add',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) {
        final initialType = state.uri.queryParameters['type'];
        final editId = state.uri.queryParameters['editId'];
        return AddTransactionScreen(
          initialType: initialType,
          editTransactionId: editId,
        );
      },
    ),
    GoRoute(
      path: '/transactions/details/:id',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) {
        final id = state.pathParameters['id']!;
        return TransactionDetailsScreen(transactionId: id);
      },
    ),
    GoRoute(
      path: '/categories',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const CategoriesScreen(),
    ),

    // Accounts
    GoRoute(
      path: '/accounts',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const AccountsOverviewScreen(),
    ),
    GoRoute(
      path: '/accounts/add',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) {
        final editId = state.uri.queryParameters['editId'];
        return AddAccountScreen(editAccountId: editId);
      },
    ),
    GoRoute(
      path: '/accounts/details/:id',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) {
        final id = state.pathParameters['id']!;
        return AccountDetailsScreen(accountId: id);
      },
    ),

    // Budgets
    GoRoute(
      path: '/budgets/create',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) {
        final editId = state.uri.queryParameters['editId'];
        return CreateBudgetScreen(editBudgetId: editId);
      },
    ),
    GoRoute(
      path: '/budgets/details/:id',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) {
        final id = state.pathParameters['id']!;
        return BudgetDetailsScreen(budgetId: id);
      },
    ),

    // Savings Goals
    GoRoute(
      path: '/savings',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const SavingsGoalsScreen(),
    ),
    GoRoute(
      path: '/savings/create',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) {
        final editId = state.uri.queryParameters['editId'];
        return CreateGoalScreen(editGoalId: editId);
      },
    ),
    GoRoute(
      path: '/savings/details/:id',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) {
        final id = state.pathParameters['id']!;
        return GoalDetailsScreen(goalId: id);
      },
    ),

    // Investments
    GoRoute(
      path: '/investments',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const InvestmentsScreen(),
    ),
    GoRoute(
      path: '/investments/add',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) {
        final editId = state.uri.queryParameters['editId'];
        return AddInvestmentScreen(editInvestmentId: editId);
      },
    ),
    GoRoute(
      path: '/investments/details/:id',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) {
        final id = state.pathParameters['id']!;
        return InvestmentDetailsScreen(investmentId: id);
      },
    ),

    // Loans
    GoRoute(
      path: '/loans',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const LoansScreen(),
    ),
    GoRoute(
      path: '/loans/add',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) {
        final editId = state.uri.queryParameters['editId'];
        return AddLoanScreen(editLoanId: editId);
      },
    ),
    GoRoute(
      path: '/loans/details/:id',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) {
        final id = state.pathParameters['id']!;
        return LoanDetailsScreen(loanId: id);
      },
    ),

    // Subscriptions
    GoRoute(
      path: '/subscriptions',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const SubscriptionsScreen(),
    ),
    GoRoute(
      path: '/subscriptions/add',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) {
        final editId = state.uri.queryParameters['editId'];
        return AddSubscriptionScreen(editSubscriptionId: editId);
      },
    ),
    GoRoute(
      path: '/subscriptions/details/:id',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) {
        final id = state.pathParameters['id']!;
        return SubscriptionDetailsScreen(subscriptionId: id);
      },
    ),

    // AI Intelligence Features
    GoRoute(
      path: '/ai/spending-analysis',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const AISpendingAnalysisScreen(),
    ),
    GoRoute(
      path: '/ai/forecast',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const AIForecastScreen(),
    ),
    GoRoute(
      path: '/ai/health-score',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const FinancialHealthScreen(),
    ),

    // Receipt Scanner
    GoRoute(
      path: '/receipt-scanner',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const ReceiptScannerScreen(),
    ),

    // Reports
    GoRoute(
      path: '/reports',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const ReportsOverviewScreen(),
    ),
    GoRoute(
      path: '/reports/detailed',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const DetailedReportsScreen(),
    ),

    // Notifications
    GoRoute(
      path: '/notifications',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const NotificationsScreen(),
    ),

    // Settings
    GoRoute(
      path: '/settings',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const SettingsScreen(),
    ),
  ],
);
