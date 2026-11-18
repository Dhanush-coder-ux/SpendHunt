import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../app/theme/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/models/transaction.dart';
import '../../../core/providers/finance_provider.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../shared/widgets/confirmation_dialog.dart';
import '../../../shared/widgets/fin_animated_icon.dart';
import '../../../shared/widgets/fin_list_tile.dart';
import '../../../shared/widgets/fin_section.dart';
import '../../../shared/widgets/section_header.dart';

class AccountDetailsScreen extends ConsumerWidget {
  final String accountId;

  const AccountDetailsScreen({super.key, required this.accountId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final finance = ref.watch(financeProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final width = MediaQuery.of(context).size.width;
    final isDesktop = width >= AppConstants.tabletBreakpoint;

    final account = finance.accounts.firstWhere(
      (a) => a.id == accountId,
      orElse: () => finance.accounts.first,
    );

    final accountTxs = finance.transactions
        .where((t) => t.accountId == account.id || t.destinationAccountId == account.id)
        .toList();
    accountTxs.sort((a, b) => b.date.compareTo(a.date));

    double totalInflow = 0.0;
    double totalOutflow = 0.0;
    for (var tx in accountTxs) {
      if (tx.type == TransactionType.income ||
          (tx.type == TransactionType.transfer && tx.destinationAccountId == account.id)) {
        totalInflow += tx.amount;
      } else {
        totalOutflow += tx.amount;
      }
    }

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      appBar: AppBar(
        title: Text(account.name, maxLines: 1, overflow: TextOverflow.ellipsis),
        actions: [
          IconButton(
            onPressed: () async {
              final confirmed = await ConfirmationDialog.show(
                context,
                title: 'Delete Account',
                message: 'Are you sure you want to delete "${account.name}"? Transactions tied to this account will remain in history.',
                confirmLabel: 'Delete',
                isDestructive: true,
              );
              if (confirmed == true && context.mounted) {
                ref.read(financeProvider.notifier).deleteAccount(account.id);
                context.pop();
              }
            },
            icon: const Icon(LucideIcons.trash2, size: 19, color: AppColors.error),
            tooltip: 'Delete Account',
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
                // Account Summary Section
                FinSection(
                  padding: const EdgeInsets.all(22),
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            account.institution,
                            style: TextStyle(
                              fontSize: 13,
                              color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: isDark ? AppColors.surfaceSecondaryDark : AppColors.surfaceSecondaryLight,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            '•••• ${account.lastFourDigits}',
                            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      account.name,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      CurrencyFormatter.format(account.balance, currencyCode: account.currency, showDecimals: true),
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.w700,
                        color: account.balance < 0 ? AppColors.error : (isDark ? Colors.white : AppColors.deepForest),
                        letterSpacing: -0.8,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Account Type: ${account.type.name.toUpperCase()} • Currency: ${account.currency}',
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Inflow vs Outflow Mini Panels
                Row(
                  children: [
                    Expanded(
                      child: FinSection(
                        padding: const EdgeInsets.all(16),
                        children: [
                          const Row(
                            children: [
                              FinAnimatedIcon(
                                icon: LucideIcons.arrowDownLeft,
                                size: 16,
                                color: AppColors.success,
                              ),
                              SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  'Total Inflow',
                                  style: TextStyle(fontSize: 12, color: AppColors.textSecondaryLight),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '+${CurrencyFormatter.format(totalInflow, currencyCode: account.currency)}',
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.success),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: FinSection(
                        padding: const EdgeInsets.all(16),
                        children: [
                          const Row(
                            children: [
                              FinAnimatedIcon(
                                icon: LucideIcons.arrowUpRight,
                                size: 16,
                                color: AppColors.warmBronze,
                              ),
                              SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  'Total Outflow',
                                  style: TextStyle(fontSize: 12, color: AppColors.textSecondaryLight),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '-${CurrencyFormatter.format(totalOutflow, currencyCode: account.currency)}',
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.warmBronze),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 22),

                // Transactions linked to this account
                SectionHeader(
                  title: 'Account Activity',
                  subtitle: '${accountTxs.length} transactions recorded',
                ),
                const SizedBox(height: 10),

                if (accountTxs.isEmpty)
                  FinSection(
                    padding: const EdgeInsets.all(24),
                    children: [
                      Center(
                        child: Text(
                          'No transactions recorded for this account yet.',
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
                    children: List.generate(accountTxs.length, (index) {
                      final tx = accountTxs[index];
                      final isLast = index == accountTxs.length - 1;
                      final isIncome = tx.type == TransactionType.income ||
                          (tx.type == TransactionType.transfer && tx.destinationAccountId == account.id);

                      return FinListTile(
                        onTap: () => context.push('/transactions/details/${tx.id}'),
                        leading: FinAnimatedIcon(
                          icon: isIncome ? LucideIcons.arrowDownLeft : LucideIcons.arrowUpRight,
                          size: 18,
                          color: isIncome ? AppColors.success : AppColors.warmBronze,
                          backgroundColor: (isIncome ? AppColors.success : AppColors.warmBronze).withValues(alpha: 0.12),
                          backgroundSize: 38,
                          borderRadius: 10,
                        ),
                        title: tx.title,
                        subtitle: '${tx.categoryName} • ${DateFormatter.formatRelative(tx.date)}',
                        trailingTitle:
                            '${isIncome ? "+" : "-"}${CurrencyFormatter.format(tx.amount, currencyCode: account.currency)}',
                        trailingSubtitle: DateFormatter.formatTime(tx.date),
                        trailingTitleColor: isIncome ? AppColors.success : (isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight),
                        showDivider: !isLast,
                      );
                    }),
                  ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
