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
import '../../../shared/widgets/fin_section.dart';

class TransactionDetailsScreen extends ConsumerWidget {
  final String transactionId;

  const TransactionDetailsScreen({super.key, required this.transactionId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final finance = ref.watch(financeProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final width = MediaQuery.of(context).size.width;
    final isDesktop = width >= AppConstants.tabletBreakpoint;

    final tx = finance.transactions.where((t) => t.id == transactionId).firstOrNull;

    if (tx == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Transaction Details')),
        body: const Center(child: Text('Transaction record not found')),
      );
    }

    final isIncome = tx.type == TransactionType.income;
    final isTransfer = tx.type == TransactionType.transfer;

    Color accentColor;
    if (isIncome) {
      accentColor = AppColors.success;
    } else if (isTransfer) {
      accentColor = isDark ? AppColors.sage : AppColors.deepForest;
    } else {
      accentColor = isDark ? AppColors.textPrimaryDark : AppColors.deepForest;
    }

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      appBar: AppBar(
        title: const Text('Transaction Details'),
        actions: [
          IconButton(
            onPressed: () => context.push('/transactions/add?editId=${tx.id}'),
            icon: const Icon(LucideIcons.pencil, size: 19),
            tooltip: 'Edit Transaction',
          ),
          IconButton(
            onPressed: () async {
              final confirmed = await ConfirmationDialog.show(
                context,
                title: 'Delete Transaction',
                message: 'Are you sure you want to permanently delete this transaction record?',
                confirmLabel: 'Delete',
                isDestructive: true,
              );
              if (confirmed == true && context.mounted) {
                ref.read(financeProvider.notifier).deleteTransaction(tx.id);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Transaction deleted')),
                );
                context.pop();
              }
            },
            icon: const Icon(LucideIcons.trash2, size: 19, color: AppColors.error),
            tooltip: 'Delete Transaction',
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 680),
            child: ListView(
              padding: EdgeInsets.symmetric(
                horizontal: isDesktop ? 24 : 18,
                vertical: 18,
              ),
              children: [
                // Top Hero Section
                FinSection(
                  padding: const EdgeInsets.symmetric(vertical: 26, horizontal: 20),
                  children: [
                    Center(
                      child: Column(
                        children: [
                          FinAnimatedIcon(
                            icon: isIncome
                                ? LucideIcons.arrowDownLeft
                                : (isTransfer ? LucideIcons.arrowLeftRight : LucideIcons.shoppingBag),
                            size: 26,
                            color: accentColor,
                            backgroundColor: accentColor.withValues(alpha: 0.12),
                            backgroundSize: 56,
                            borderRadius: 28,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            '${isIncome ? "+" : (isTransfer ? "" : "-")}${CurrencyFormatter.format(tx.amount, currencyCode: finance.profile.currency)}',
                            style: TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.w700,
                              letterSpacing: -0.8,
                              color: accentColor,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            tx.title,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                            ),
                            textAlign: TextAlign.center,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${tx.merchant} • ${DateFormatter.format(tx.date)} at ${DateFormatter.formatTime(tx.date)}',
                            style: TextStyle(
                              fontSize: 12.5,
                              color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                            ),
                            textAlign: TextAlign.center,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Detailed Key-Value Rows
                FinSection(
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                  children: [
                    _buildDetailRow(
                      context,
                      icon: LucideIcons.layers,
                      label: 'Type',
                      value: tx.type.displayName,
                    ),
                    const Divider(),
                    _buildDetailRow(
                      context,
                      icon: LucideIcons.shapes,
                      label: 'Category',
                      value: tx.categoryName,
                    ),
                    const Divider(),
                    _buildDetailRow(
                      context,
                      icon: LucideIcons.wallet,
                      label: isTransfer ? 'From Account' : 'Account',
                      value: tx.accountName,
                    ),
                    if (isTransfer && tx.destinationAccountName != null) ...[
                      const Divider(),
                      _buildDetailRow(
                        context,
                        icon: LucideIcons.arrowRightLeft,
                        label: 'To Account',
                        value: tx.destinationAccountName!,
                      ),
                    ],
                    const Divider(),
                    _buildDetailRow(
                      context,
                      icon: LucideIcons.creditCard,
                      label: 'Payment Method',
                      value: tx.paymentMethod,
                    ),
                    const Divider(),
                    _buildDetailRow(
                      context,
                      icon: LucideIcons.calendar,
                      label: 'Date & Time',
                      value: '${DateFormatter.format(tx.date)} ${DateFormatter.formatTime(tx.date)}',
                    ),
                    if (tx.notes != null && tx.notes!.isNotEmpty) ...[
                      const Divider(),
                      _buildDetailRow(
                        context,
                        icon: LucideIcons.fileText,
                        label: 'Notes / Memo',
                        value: tx.notes!,
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 16),

                // Simulated Receipt Preview
                if (tx.receiptPath != null) ...[
                  FinSection(
                    padding: const EdgeInsets.all(16),
                    children: [
                      const Row(
                        children: [
                          FinAnimatedIcon(icon: LucideIcons.fileCheck, size: 18, color: AppColors.success),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Receipt Document Attached',
                              style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w600),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Container(
                        height: 120,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: isDark ? AppColors.surfaceSecondaryDark : AppColors.surfaceSecondaryLight,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isDark ? AppColors.borderDark : AppColors.borderLight,
                          ),
                        ),
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              FinAnimatedIcon(
                                icon: LucideIcons.receipt,
                                size: 36,
                                color: isDark ? AppColors.sage : AppColors.deepForest,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                tx.receiptPath!,
                                style: const TextStyle(fontSize: 11.5, color: AppColors.textSecondaryLight),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          FinAnimatedIcon(icon: icon, size: 17, color: AppColors.sage),
          const SizedBox(width: 12),
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: TextStyle(
                fontSize: 13.5,
                fontWeight: FontWeight.w600,
                color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
