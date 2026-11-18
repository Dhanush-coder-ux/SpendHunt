import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../app/theme/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/models/budget.dart';
import '../../../core/providers/finance_provider.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../../shared/widgets/fin_animated_icon.dart';
import '../../../shared/widgets/fin_section.dart';

class BudgetsOverviewScreen extends ConsumerWidget {
  const BudgetsOverviewScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final finance = ref.watch(financeProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final width = MediaQuery.of(context).size.width;
    final isDesktop = width >= AppConstants.tabletBreakpoint;

    double totalBudget = 0.0;
    double totalSpent = 0.0;
    for (var b in finance.budgets) {
      totalBudget += b.amount;
      totalSpent += finance.getSpentForCategory(b.categoryId);
    }
    final overallUtilization = totalBudget > 0 ? (totalSpent / totalBudget).clamp(0.0, 1.0) : 0.0;
    final remainingBudget = (totalBudget - totalSpent).clamp(0, double.infinity);

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      appBar: AppBar(
        title: const Text('Budget Planning', style: TextStyle(fontWeight: FontWeight.w700)),
        actions: [
          IconButton(
            onPressed: () => context.push('/budgets/create'),
            icon: const Icon(LucideIcons.plus, size: 20),
            tooltip: 'Create Budget',
          ),
          const SizedBox(width: 8),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/budgets/create'),
        backgroundColor: AppColors.deepForest,
        foregroundColor: Colors.white,
        icon: const Icon(LucideIcons.plus, size: 18),
        label: const Text('New Budget', style: TextStyle(fontWeight: FontWeight.w600)),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(
            horizontal: isDesktop ? 32 : 18,
            vertical: 18,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Hero Budget Summary Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  color: AppColors.deepForest,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            'OVERALL MONTHLY BUDGET',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.8,
                              color: Colors.white.withValues(alpha: 0.7),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '${(overallUtilization * 100).toStringAsFixed(0)}% Used',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: AppColors.goldenYellow,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      CurrencyFormatter.format(
                        totalBudget,
                        currencyCode: finance.profile.currency,
                      ),
                      style: const TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.8,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Overall Progress Bar
                    ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: LinearProgressIndicator(
                        value: overallUtilization,
                        backgroundColor: Colors.white.withValues(alpha: 0.15),
                        valueColor: AlwaysStoppedAnimation<Color>(
                          overallUtilization > 0.9 ? AppColors.error : AppColors.goldenYellow,
                        ),
                        minHeight: 7,
                      ),
                    ),
                    const SizedBox(height: 14),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            'Spent: ${CurrencyFormatter.format(totalSpent, currencyCode: finance.profile.currency)}',
                            style: TextStyle(
                              fontSize: 12.5,
                              color: Colors.white.withValues(alpha: 0.8),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Remaining: ${CurrencyFormatter.format(remainingBudget.toDouble(), currencyCode: finance.profile.currency)}',
                          style: const TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              Text(
                'CATEGORY BUDGET TARGETS',
                style: TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.8,
                  color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                ),
              ),
              const SizedBox(height: 12),

              if (finance.budgets.isEmpty)
                EmptyState(
                  title: 'No budgets created',
                  description: 'Set spending caps on groceries, entertainment, dining, and bills.',
                  icon: LucideIcons.pieChart,
                  actionLabel: 'Create Budget',
                  onAction: () => context.push('/budgets/create'),
                )
              else
                FinSection(
                  children: List.generate(finance.budgets.length, (index) {
                    final bgt = finance.budgets[index];
                    final isLast = index == finance.budgets.length - 1;
                    return _buildBudgetRow(context, bgt, finance, isDark, !isLast);
                  }),
                ),
              const SizedBox(height: 60),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBudgetRow(
    BuildContext context,
    Budget bgt,
    FinanceState finance,
    bool isDark,
    bool showDivider,
  ) {
    final spent = finance.getSpentForCategory(bgt.categoryId);
    final progress = bgt.amount > 0 ? (spent / bgt.amount).clamp(0.0, 1.0) : 0.0;
    final remaining = (bgt.amount - spent).clamp(0, double.infinity);
    final isExceeded = spent > bgt.amount;
    final isApproaching = progress >= bgt.alertThreshold && !isExceeded;

    Color statusColor;
    String statusText;
    if (isExceeded) {
      statusColor = AppColors.error;
      statusText = 'Exceeded';
    } else if (isApproaching) {
      statusColor = AppColors.warning;
      statusText = 'Near Limit';
    } else {
      statusColor = isDark ? AppColors.sage : AppColors.deepForest;
      statusText = 'On Track';
    }

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => context.push('/budgets/details/${bgt.id}'),
        splashColor: AppColors.sage.withValues(alpha: 0.1),
        highlightColor: AppColors.sage.withValues(alpha: 0.05),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      FinAnimatedIcon(
                        icon: LucideIcons.pieChart,
                        size: 18,
                        color: statusColor,
                        backgroundColor: statusColor.withValues(alpha: 0.12),
                        backgroundSize: 38,
                        borderRadius: 10,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              bgt.name,
                              style: TextStyle(
                                fontSize: 14.5,
                                fontWeight: FontWeight.w600,
                                color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Cap: ${CurrencyFormatter.format(bgt.amount, currencyCode: finance.profile.currency)} (${bgt.period.displayName})',
                              style: TextStyle(
                                fontSize: 11.5,
                                color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: statusColor.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          statusText,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: statusColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: LinearProgressIndicator(
                      value: progress,
                      backgroundColor: isDark ? AppColors.surfaceSecondaryDark : AppColors.surfaceSecondaryLight,
                      valueColor: AlwaysStoppedAnimation<Color>(statusColor),
                      minHeight: 6,
                    ),
                  ),
                  const SizedBox(height: 10),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          'Spent: ${CurrencyFormatter.format(spent, currencyCode: finance.profile.currency)}',
                          style: TextStyle(
                            fontSize: 12,
                            color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        isExceeded
                            ? 'Over by ${CurrencyFormatter.format(spent - bgt.amount, currencyCode: finance.profile.currency)}'
                            : 'Left: ${CurrencyFormatter.format(remaining.toDouble(), currencyCode: finance.profile.currency)}',
                        style: TextStyle(
                          fontSize: 12.0,
                          fontWeight: FontWeight.w600,
                          color: isExceeded
                              ? AppColors.error
                              : (isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            if (showDivider)
              Divider(
                height: 1,
                thickness: 0.8,
                indent: 66,
                endIndent: 16,
                color: (isDark ? AppColors.borderDark : AppColors.borderLight).withValues(alpha: 0.65),
              ),
          ],
        ),
      ),
    );
  }
}
