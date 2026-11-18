import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../app/theme/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/models/transaction.dart';
import '../../../core/providers/finance_provider.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../shared/widgets/fin_animated_icon.dart';
import '../../../shared/widgets/fin_section.dart';
import '../../../shared/widgets/section_header.dart';

class AISpendingAnalysisScreen extends ConsumerWidget {
  const AISpendingAnalysisScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final finance = ref.watch(financeProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final width = MediaQuery.of(context).size.width;
    final isDesktop = width >= AppConstants.tabletBreakpoint;

    final totalExpense = finance.totalExpenseThisMonth;

    // Aggregate category spend
    final Map<String, double> catMap = {};
    for (var tx in finance.transactions) {
      if (tx.type == TransactionType.expense) {
        catMap[tx.categoryName] = (catMap[tx.categoryName] ?? 0) + tx.amount;
      }
    }
    final sortedCats = catMap.entries.toList()..sort((a, b) => b.value.compareTo(a.value));

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      appBar: AppBar(
        title: const Text('AI Spending Analysis'),
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 760),
            child: ListView(
              padding: EdgeInsets.symmetric(
                horizontal: isDesktop ? 32 : 18,
                vertical: 18,
              ),
              children: [
                // Top Executive Insight
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppColors.deepForest,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.goldenYellow.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Row(
                              children: [
                                Icon(LucideIcons.sparkles, size: 12, color: AppColors.goldenYellow),
                                SizedBox(width: 5),
                                Text(
                                  'AI DIAGNOSTIC REPORT',
                                  style: TextStyle(
                                    fontSize: 10.5,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.goldenYellow,
                                    letterSpacing: 0.6,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Spacer(),
                          Text(
                            'Current Month',
                            style: TextStyle(fontSize: 12, color: Colors.white.withValues(alpha: 0.7)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      Text(
                        'Total Outflow: ${CurrencyFormatter.format(totalExpense, currencyCode: finance.profile.currency)}',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Overall spending run-rate is 6.2% lower than last month, driven by lower utility expenditures. However, weekend dining saw a 14% uptick.',
                        style: TextStyle(
                          fontSize: 13.5,
                          height: 1.45,
                          color: Colors.white.withValues(alpha: 0.85),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 22),

                // Top Spending Categories
                const SectionHeader(
                  title: 'Primary Cost Drivers',
                  subtitle: 'Categories consuming over 60% of monthly outflows',
                ),
                const SizedBox(height: 10),

                FinSection(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Column(
                    children: [
                      for (int i = 0; i < sortedCats.take(4).length; i++) ...[
                        () {
                          final cat = sortedCats[i];
                          final pct = totalExpense > 0 ? (cat.value / totalExpense) * 100 : 0.0;
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        cat.key,
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                          color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      CurrencyFormatter.format(cat.value, currencyCode: finance.profile.currency),
                                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(4),
                                  child: LinearProgressIndicator(
                                    value: (pct / 100).clamp(0.0, 1.0),
                                    backgroundColor: isDark ? AppColors.surfaceSecondaryDark : AppColors.surfaceSecondaryLight,
                                    valueColor: const AlwaysStoppedAnimation<Color>(AppColors.warmBronze),
                                    minHeight: 5,
                                  ),
                                ),
                                const SizedBox(height: 5),
                                Text(
                                  '${pct.toStringAsFixed(1)}% of total monthly spend',
                                  style: const TextStyle(fontSize: 11.5, color: AppColors.textSecondaryLight),
                                ),
                              ],
                            ),
                          );
                        }(),
                        if (i < sortedCats.take(4).length - 1)
                          Divider(
                            height: 1,
                            thickness: 1,
                            color: isDark ? AppColors.borderDark : AppColors.borderLight,
                          ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Unusual Spending Detected
                const SectionHeader(
                  title: 'Anomalies & Unusual Charges',
                  subtitle: 'Transactions diverging from 90-day baseline patterns',
                ),
                const SizedBox(height: 10),

                FinSection(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppColors.warning.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const FinAnimatedIcon(
                          icon: LucideIcons.triangleAlert,
                          color: AppColors.warning,
                          size: 18,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Uniqlo Apparel (₹6,990)',
                              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Discretionary apparel purchase was 2.3x higher than your average monthly clothing transactions.',
                              style: TextStyle(
                                fontSize: 12.5,
                                color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                                height: 1.4,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Savings Opportunities
                const SectionHeader(
                  title: 'Savings Opportunities',
                  subtitle: 'Actionable recommendations generated by FinPilot AI',
                ),
                const SizedBox(height: 10),

                FinSection(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Column(
                    children: [
                      _buildOpportunityRow(
                        isDark: isDark,
                        icon: LucideIcons.coffee,
                        title: 'Optimize Café & Takeout Orders',
                        potentialSavings: '₹2,400/mo',
                        detail: 'You made 8 cafe transactions this month. Preparing coffee at home 3 days a week yields ~₹28,800 annual compounding.',
                      ),
                      Divider(
                        height: 1,
                        thickness: 1,
                        color: isDark ? AppColors.borderDark : AppColors.borderLight,
                      ),
                      _buildOpportunityRow(
                        isDark: isDark,
                        icon: LucideIcons.tv,
                        title: 'Audit Recurring Subscriptions',
                        potentialSavings: '₹1,100/mo',
                        detail: 'You have 6 active recurring entertainment and app plans totaling ₹6,392/month. Consolidating underused plans optimizes cash flow.',
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildOpportunityRow({
    required bool isDark,
    required IconData icon,
    required String title,
    required String potentialSavings,
    required String detail,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              FinAnimatedIcon(icon: icon, size: 16, color: AppColors.success),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w600,
                    color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                potentialSavings,
                style: const TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w700,
                  color: AppColors.success,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            detail,
            style: TextStyle(
              fontSize: 12,
              color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}
