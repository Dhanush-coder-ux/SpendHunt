import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/models/budget.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../shared/widgets/fin_animated_icon.dart';
import '../../../../shared/widgets/fin_section.dart';
import '../../../../shared/widgets/section_header.dart';

class BudgetOverviewWidget extends StatelessWidget {
  final List<Budget> budgets;
  final double Function(String categoryId) getSpent;
  final String currency;

  const BudgetOverviewWidget({
    super.key,
    required this.budgets,
    required this.getSpent,
    this.currency = 'INR',
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final displayBudgets = budgets.take(3).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(
          title: 'Budget Tracking',
          actionLabel: 'View All',
          onAction: () => context.go('/budgets'),
        ),
        const SizedBox(height: 10),
        FinSection(
          children: List.generate(displayBudgets.length, (index) {
            final bgt = displayBudgets[index];
            final isLast = index == displayBudgets.length - 1;
            final spent = getSpent(bgt.categoryId);
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
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
                                backgroundSize: 36,
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
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      'Remaining: ${CurrencyFormatter.format(remaining.toDouble(), currencyCode: currency)}',
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
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    CurrencyFormatter.format(spent, currencyCode: currency),
                                    style: TextStyle(
                                      fontSize: 13.5,
                                      fontWeight: FontWeight.w700,
                                      color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    statusText,
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                      color: statusColor,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: LinearProgressIndicator(
                              value: progress,
                              backgroundColor: isDark ? AppColors.surfaceSecondaryDark : AppColors.surfaceSecondaryLight,
                              valueColor: AlwaysStoppedAnimation<Color>(statusColor),
                              minHeight: 5,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (!isLast)
                      Divider(
                        height: 1,
                        thickness: 0.8,
                        indent: 64,
                        endIndent: 16,
                        color: (isDark ? AppColors.borderDark : AppColors.borderLight).withValues(alpha: 0.65),
                      ),
                  ],
                ),
              ),
            );
          }),
        ),
      ],
    );
  }
}
