import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/models/transaction.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../shared/widgets/fin_animated_icon.dart';
import '../../../../shared/widgets/fin_list_tile.dart';
import '../../../../shared/widgets/fin_section.dart';
import '../../../../shared/widgets/section_header.dart';

class RecentActivityWidget extends StatelessWidget {
  final List<TransactionModel> transactions;
  final String currency;

  const RecentActivityWidget({
    super.key,
    required this.transactions,
    this.currency = 'INR',
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final latest5 = transactions.take(5).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(
          title: 'Recent Activity',
          actionLabel: 'View All',
          onAction: () => context.go('/transactions'),
        ),
        const SizedBox(height: 10),
        FinSection(
          children: List.generate(latest5.length, (index) {
            final tx = latest5[index];
            final isLast = index == latest5.length - 1;
            final isIncome = tx.type == TransactionType.income;
            final isTransfer = tx.type == TransactionType.transfer;

            final iconData = isIncome
                ? LucideIcons.arrowDownLeft
                : (isTransfer ? LucideIcons.arrowLeftRight : LucideIcons.shoppingBag);

            final iconColor = isIncome
                ? AppColors.success
                : (isTransfer
                    ? AppColors.sage
                    : (isDark ? AppColors.textPrimaryDark : AppColors.deepForest));

            final iconBg = isIncome
                ? AppColors.success.withValues(alpha: 0.12)
                : (isTransfer
                    ? AppColors.sage.withValues(alpha: 0.12)
                    : (isDark
                        ? AppColors.surfaceSecondaryDark
                        : AppColors.surfaceSecondaryLight));

            return FinListTile(
              onTap: () => context.push('/transactions/details/${tx.id}'),
              leading: FinAnimatedIcon(
                icon: iconData,
                size: 18,
                color: iconColor,
                backgroundColor: iconBg,
                backgroundSize: 40,
                borderRadius: 12,
              ),
              title: tx.title,
              subtitle: '${tx.categoryName} • ${DateFormatter.formatRelative(tx.date)}',
              trailingTitle:
                  '${isIncome ? "+" : (isTransfer ? "" : "-")}${CurrencyFormatter.format(tx.amount, currencyCode: currency)}',
              trailingSubtitle: DateFormatter.formatTime(tx.date),
              trailingTitleColor: isIncome
                  ? AppColors.success
                  : (isTransfer
                      ? (isDark ? AppColors.textPrimaryDark : AppColors.deepForest)
                      : (isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight)),
              showDivider: !isLast,
            );
          }),
        ),
      ],
    );
  }
}
