import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../app/theme/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/models/budget.dart';
import '../../../core/providers/finance_provider.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../shared/widgets/confirmation_dialog.dart';
import '../../../shared/widgets/fin_animated_icon.dart';
import '../../../shared/widgets/fin_list_tile.dart';
import '../../../shared/widgets/fin_section.dart';
import '../../../shared/widgets/section_header.dart';

class BudgetDetailsScreen extends ConsumerWidget {
  final String budgetId;

  const BudgetDetailsScreen({super.key, required this.budgetId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final finance = ref.watch(financeProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final width = MediaQuery.of(context).size.width;
    final isDesktop = width >= AppConstants.tabletBreakpoint;

    final budget = finance.budgets.firstWhere(
      (b) => b.id == budgetId,
      orElse: () => finance.budgets.first,
    );

    final spent = finance.getSpentForCategory(budget.categoryId);
    final progress = budget.amount > 0 ? (spent / budget.amount).clamp(0.0, 1.0) : 0.0;
    final remaining = (budget.amount - spent).clamp(0, double.infinity);
    final isExceeded = spent > budget.amount;
    final isApproaching = progress >= budget.alertThreshold && !isExceeded;

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

    final categoryTxs = finance.transactions
        .where((t) => t.categoryId == budget.categoryId)
        .toList();
    categoryTxs.sort((a, b) => b.date.compareTo(a.date));

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      appBar: AppBar(
        title: Text(budget.name, maxLines: 1, overflow: TextOverflow.ellipsis),
        actions: [
          IconButton(
            onPressed: () async {
              final confirmed = await ConfirmationDialog.show(
                context,
                title: 'Delete Budget',
                message: 'Are you sure you want to delete "${budget.name}"? Your past transactions will remain unaffected.',
              );
              if (confirmed == true && context.mounted) {
                ref.read(financeProvider.notifier).deleteBudget(budget.id);
                context.pop();
              }
            },
            icon: const Icon(LucideIcons.trash2, size: 19, color: AppColors.error),
            tooltip: 'Delete Budget',
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 720),
            child: ListView(
              padding: EdgeInsets.symmetric(
                horizontal: isDesktop ? 24 : 18,
                vertical: 18,
              ),
              children: [
                // Hero Budget Section
                FinSection(
                  padding: const EdgeInsets.all(22),
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            '${budget.period.displayName} Allocation',
                            style: TextStyle(
                              fontSize: 12.5,
                              color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
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
                    Text(
                      budget.name,
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      CurrencyFormatter.format(budget.amount, currencyCode: finance.profile.currency),
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.w700,
                        color: isDark ? Colors.white : AppColors.deepForest,
                        letterSpacing: -0.8,
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Progress bar
                    ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: LinearProgressIndicator(
                        value: progress,
                        backgroundColor: isDark ? AppColors.surfaceSecondaryDark : AppColors.surfaceSecondaryLight,
                        valueColor: AlwaysStoppedAnimation<Color>(statusColor),
                        minHeight: 8,
                      ),
                    ),
                    const SizedBox(height: 14),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildInfoColumn('Spent to Date', CurrencyFormatter.format(spent, currencyCode: finance.profile.currency), isDark),
                        _buildInfoColumn('Remaining', CurrencyFormatter.format(remaining.toDouble(), currencyCode: finance.profile.currency), isDark),
                        _buildInfoColumn('Budget Utilization', '${(progress * 100).toStringAsFixed(0)}%', isDark),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 22),

                // Transactions under this budget
                SectionHeader(
                  title: 'Associated Category Outflows',
                  subtitle: '${categoryTxs.length} transactions contributing to this budget',
                ),
                const SizedBox(height: 10),

                if (categoryTxs.isEmpty)
                  FinSection(
                    padding: const EdgeInsets.all(24),
                    children: [
                      Center(
                        child: Text(
                          'No transactions recorded under this category yet.',
                          style: TextStyle(
                            color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ],
                  )
                else
                  FinSection(
                    children: List.generate(categoryTxs.length, (index) {
                      final tx = categoryTxs[index];
                      final isLast = index == categoryTxs.length - 1;

                      return FinListTile(
                        onTap: () => context.push('/transactions/details/${tx.id}'),
                        leading: const FinAnimatedIcon(
                          icon: LucideIcons.shoppingBag,
                          size: 18,
                          color: AppColors.warmBronze,
                          backgroundColor: Color(0x1FBB8A52),
                          backgroundSize: 38,
                          borderRadius: 10,
                        ),
                        title: tx.title,
                        subtitle: '${tx.accountName} • ${DateFormatter.formatRelative(tx.date)}',
                        trailingTitle: '-${CurrencyFormatter.format(tx.amount, currencyCode: finance.profile.currency)}',
                        trailingSubtitle: DateFormatter.formatTime(tx.date),
                        trailingTitleColor: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                        showDivider: !isLast,
                      );
                    }),
                  ),
                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoColumn(String label, String value, bool isDark) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          value,
          style: TextStyle(
            fontSize: 13.5,
            fontWeight: FontWeight.w700,
            color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
          ),
        ),
      ],
    );
  }
}
