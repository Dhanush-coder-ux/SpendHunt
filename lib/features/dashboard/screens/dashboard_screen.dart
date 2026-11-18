import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../app/theme/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/providers/finance_provider.dart';
import '../../../core/providers/notification_provider.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../shared/widgets/fin_animated_icon.dart';
import '../widgets/balance_card.dart';
import '../widgets/cash_flow_chart.dart';
import '../widgets/expense_category_chart.dart';
import '../widgets/quick_actions_bar.dart';
import '../widgets/budget_overview_widget.dart';
import '../widgets/ai_insight_card.dart';
import '../widgets/upcoming_bills_widget.dart';
import '../widgets/recent_activity_widget.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  String _getTimeBasedGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return 'Good morning';
    } else if (hour < 17) {
      return 'Good afternoon';
    } else {
      return 'Good evening';
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final finance = ref.watch(financeProvider);
    final unreadCount = ref.watch(unreadNotificationCountProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final width = MediaQuery.of(context).size.width;
    final isDesktop = width >= AppConstants.tabletBreakpoint;

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(
            horizontal: isDesktop ? 32 : 18,
            vertical: 18,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Row (Mobile)
              if (!isDesktop) ...[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          InkWell(
                            onTap: () => context.go('/profile'),
                            borderRadius: BorderRadius.circular(22),
                            child: Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                color: AppColors.deepForest,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: AppColors.warmBronze,
                                  width: 1.5,
                                ),
                              ),
                              child: const Center(
                                child: Text(
                                  'DK',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _getTimeBasedGreeting(),
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: isDark
                                        ? AppColors.textSecondaryDark
                                        : AppColors.textSecondaryLight,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                Text(
                                  finance.profile.name,
                                  style: TextStyle(
                                    fontSize: 17,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: -0.3,
                                    color: isDark
                                        ? AppColors.textPrimaryDark
                                        : AppColors.textPrimaryLight,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Row(
                      children: [
                        IconButton(
                          onPressed: () => context.push('/scanner'),
                          icon: const FinAnimatedIcon(
                            icon: LucideIcons.scanLine,
                            size: 20,
                            color: AppColors.deepForest,
                          ),
                          tooltip: 'Receipt Scanner',
                        ),
                        IconButton(
                          onPressed: () => context.push('/notifications'),
                          icon: Badge(
                            isLabelVisible: unreadCount > 0,
                            label: Text(
                              unreadCount.toString(),
                              style: const TextStyle(fontSize: 10, color: Colors.white),
                            ),
                            backgroundColor: AppColors.error,
                            child: FinAnimatedIcon(
                              icon: LucideIcons.bell,
                              color: isDark ? AppColors.textPrimaryDark : AppColors.deepForest,
                              size: 20,
                              pulse: unreadCount > 0,
                            ),
                          ),
                          tooltip: 'Notifications',
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 18),
              ],

              // Main Balance Card
              const BalanceCard(),
              const SizedBox(height: 16),

              // Quick Actions
              const QuickActionsBar(),
              const SizedBox(height: 18),

              // Financial Overview 4 Stats Cards
              Row(
                children: [
                  Expanded(
                    child: _buildMiniStatCard(
                      context,
                      label: 'Net Worth',
                      value: CurrencyFormatter.format(finance.netWorth, currencyCode: finance.profile.currency, compact: true),
                      icon: LucideIcons.gem,
                      color: AppColors.deepForest,
                      isDark: isDark,
                      onTap: () => context.push('/reports'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _buildMiniStatCard(
                      context,
                      label: 'Net Savings',
                      value: CurrencyFormatter.format(finance.netSavingsThisMonth, currencyCode: finance.profile.currency, compact: true),
                      icon: LucideIcons.piggyBank,
                      color: AppColors.success,
                      isDark: isDark,
                      onTap: () => context.push('/savings'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: _buildMiniStatCard(
                      context,
                      label: 'Savings Rate',
                      value: '${finance.savingsRateThisMonth.toStringAsFixed(1)}%',
                      icon: LucideIcons.percent,
                      color: AppColors.warmBronze,
                      isDark: isDark,
                      onTap: () => context.push('/reports'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _buildMiniStatCard(
                      context,
                      label: 'Investments',
                      value: CurrencyFormatter.format(finance.totalInvestmentValue, currencyCode: finance.profile.currency, compact: true),
                      icon: LucideIcons.trendingUp,
                      color: AppColors.info,
                      isDark: isDark,
                      onTap: () => context.push('/investments'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // AI Insight Card
              const AIInsightCard(),
              const SizedBox(height: 20),

              // Charts Layout (Adaptive: 2 columns on wide screens, stacked on mobile)
              if (isDesktop)
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 3,
                      child: CashFlowChart(
                        income: finance.totalIncomeThisMonth,
                        expense: finance.totalExpenseThisMonth,
                        currency: finance.profile.currency,
                        transactions: finance.transactions,
                      ),
                    ),
                    const SizedBox(width: 18),
                    Expanded(
                      flex: 2,
                      child: ExpenseCategoryChart(
                        transactions: finance.transactions,
                        currency: finance.profile.currency,
                      ),
                    ),
                  ],
                )
              else ...[
                CashFlowChart(
                  income: finance.totalIncomeThisMonth,
                  expense: finance.totalExpenseThisMonth,
                  currency: finance.profile.currency,
                  transactions: finance.transactions,
                ),
                const SizedBox(height: 18),
                ExpenseCategoryChart(
                  transactions: finance.transactions,
                  currency: finance.profile.currency,
                ),
              ],
              const SizedBox(height: 22),

              // Budget Overview Widget
              BudgetOverviewWidget(
                budgets: finance.budgets,
                getSpent: finance.getSpentForCategory,
                currency: finance.profile.currency,
              ),
              const SizedBox(height: 22),

              // Upcoming Bills / Recurring Payments
              UpcomingBillsWidget(
                subscriptions: finance.subscriptions,
                currency: finance.profile.currency,
              ),
              const SizedBox(height: 22),

              // Recent Activity (Latest 5 transactions)
              RecentActivityWidget(
                transactions: finance.transactions,
                currency: finance.profile.currency,
              ),
              const SizedBox(height: 50),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMiniStatCard(
    BuildContext context, {
    required String label,
    required String value,
    required IconData icon,
    required Color color,
    required bool isDark,
    required VoidCallback onTap,
  }) {
    return Material(
      color: isDark ? AppColors.surfaceDark : Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: (isDark ? AppColors.borderDark : AppColors.borderLight).withValues(alpha: 0.8),
          width: 1,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        splashColor: color.withValues(alpha: 0.1),
        highlightColor: color.withValues(alpha: 0.05),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Row(
            children: [
              FinAnimatedIcon(
                icon: icon,
                size: 16,
                color: color,
                backgroundColor: color.withValues(alpha: 0.12),
                backgroundSize: 34,
                borderRadius: 10,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      label,
                      style: TextStyle(
                        fontSize: 11,
                        color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      value,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
