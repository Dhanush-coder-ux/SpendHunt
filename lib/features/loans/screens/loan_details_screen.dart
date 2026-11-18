import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../app/theme/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/models/loan.dart';
import '../../../core/providers/finance_provider.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/confirmation_dialog.dart';
import '../../../shared/widgets/fin_animated_icon.dart';
import '../../../shared/widgets/fin_list_tile.dart';
import '../../../shared/widgets/fin_section.dart';
import '../../../shared/widgets/section_header.dart';

class LoanDetailsScreen extends ConsumerWidget {
  final String loanId;

  const LoanDetailsScreen({super.key, required this.loanId});

  void _recordEmiPayment(BuildContext context, WidgetRef ref, Loan loan, String currency) async {
    final confirmed = await ConfirmationDialog.show(
      context,
      title: 'Record Monthly EMI Payment',
      message: 'Record ${CurrencyFormatter.format(loan.monthlyEmi, currencyCode: currency)} towards "${loan.name}"?',
      confirmLabel: 'Record Payment',
    );

    if (confirmed == true && context.mounted) {
      ref.read(financeProvider.notifier).recordLoanPayment(
            loan.id,
            loan.monthlyEmi,
            DateTime.now(),
          );
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('EMI of ${CurrencyFormatter.format(loan.monthlyEmi, currencyCode: currency)} recorded!'),
          backgroundColor: AppColors.deepForest,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final finance = ref.watch(financeProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final width = MediaQuery.of(context).size.width;
    final isDesktop = width >= AppConstants.tabletBreakpoint;

    final loan = finance.loans.where((l) => l.id == loanId).firstOrNull;

    if (loan == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Loan Details')),
        body: const Center(child: Text('Loan not found')),
      );
    }

    final progress = loan.repaymentProgress;

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      appBar: AppBar(
        title: Text(loan.name, maxLines: 1, overflow: TextOverflow.ellipsis),
        actions: [
          IconButton(
            onPressed: () => context.push('/loans/add?editId=${loan.id}'),
            icon: const Icon(LucideIcons.pencil, size: 19),
            tooltip: 'Edit Loan',
          ),
          IconButton(
            onPressed: () async {
              final confirmed = await ConfirmationDialog.show(
                context,
                title: 'Delete Loan',
                message: 'Are you sure you want to remove "${loan.name}"?',
              );
              if (confirmed == true && context.mounted) {
                ref.read(financeProvider.notifier).deleteLoan(loan.id);
                context.pop();
              }
            },
            icon: const Icon(LucideIcons.trash2, size: 19, color: AppColors.error),
            tooltip: 'Delete Loan',
          ),
          const SizedBox(width: 8),
        ],
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? AppColors.surfaceDark : Colors.white,
          border: Border(top: BorderSide(color: (isDark ? AppColors.borderDark : AppColors.borderLight).withValues(alpha: 0.8))),
        ),
        child: SafeArea(
          child: AppButton(
            label: 'Record EMI Payment (${CurrencyFormatter.format(loan.monthlyEmi, currencyCode: finance.profile.currency)})',
            icon: LucideIcons.creditCard,
            onPressed: () => _recordEmiPayment(context, ref, loan, finance.profile.currency),
          ),
        ),
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
                // Top Outstanding Section
                FinSection(
                  padding: const EdgeInsets.all(22),
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            loan.lender,
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
                            color: isDark ? AppColors.surfaceSecondaryDark : AppColors.surfaceSecondaryLight,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            '${(progress * 100).toStringAsFixed(0)}% Repaid',
                            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      loan.name,
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
                      CurrencyFormatter.format(loan.outstandingBalance, currencyCode: finance.profile.currency),
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.8,
                        color: isDark ? AppColors.textPrimaryDark : AppColors.deepForest,
                      ),
                    ),
                    const SizedBox(height: 14),

                    ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: LinearProgressIndicator(
                        value: progress,
                        backgroundColor: isDark
                            ? AppColors.surfaceSecondaryDark
                            : AppColors.surfaceSecondaryLight,
                        valueColor: const AlwaysStoppedAnimation<Color>(AppColors.deepForest),
                        minHeight: 8,
                      ),
                    ),
                    const SizedBox(height: 12),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            'Original: ${CurrencyFormatter.format(loan.principalAmount, currencyCode: finance.profile.currency)}',
                            style: const TextStyle(fontSize: 12, color: AppColors.textSecondaryLight),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Paid: ${CurrencyFormatter.format(loan.principalAmount - loan.outstandingBalance, currencyCode: finance.profile.currency)}',
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.success),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 22),

                // Loan Terms Key Details
                const SectionHeader(title: 'Loan Terms & Commitments'),
                const SizedBox(height: 10),

                FinSection(
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                  children: [
                    _buildDetailRow('Monthly EMI', CurrencyFormatter.format(loan.monthlyEmi, currencyCode: finance.profile.currency), isDark),
                    const Divider(),
                    _buildDetailRow('Interest Rate', '${loan.annualInterestRate}% p.a.', isDark),
                    const Divider(),
                    _buildDetailRow('Tenure Duration', '${loan.tenureMonths} Months (${(loan.tenureMonths / 12).toStringAsFixed(1)} yrs)', isDark),
                    const Divider(),
                    _buildDetailRow('Loan Start Date', DateFormatter.format(loan.startDate), isDark),
                    const Divider(),
                    _buildDetailRow('Next EMI Due', DateFormatter.format(loan.nextPaymentDate), isDark),
                    const Divider(),
                    _buildDetailRow('Lending Institution', loan.lender, isDark),
                  ],
                ),
                const SizedBox(height: 22),

                // Repayment Schedule History
                SectionHeader(
                  title: 'Repayment Activity',
                  subtitle: '${loan.payments.length} installments recorded',
                ),
                const SizedBox(height: 10),

                if (loan.payments.isEmpty)
                  FinSection(
                    padding: const EdgeInsets.all(24),
                    children: [
                      Center(
                        child: Text(
                          'No installment payments recorded yet.',
                          style: TextStyle(
                            fontSize: 13,
                            color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                          ),
                        ),
                      ),
                    ],
                  )
                else
                  FinSection(
                    children: List.generate(loan.payments.length, (index) {
                      final p = loan.payments[index];
                      final isLast = index == loan.payments.length - 1;

                      return FinListTile(
                        leading: const FinAnimatedIcon(
                          icon: LucideIcons.receiptText,
                          size: 18,
                          color: AppColors.deepForest,
                          backgroundColor: Color(0x1F0C3B2E),
                          backgroundSize: 38,
                          borderRadius: 10,
                        ),
                        title: 'EMI Installment',
                        subtitle: 'Principal: ${CurrencyFormatter.format(p.principalPaid, currencyCode: finance.profile.currency)} • Int: ${CurrencyFormatter.format(p.interestPaid, currencyCode: finance.profile.currency)}',
                        trailingTitle: CurrencyFormatter.format(p.amount, currencyCode: finance.profile.currency),
                        trailingSubtitle: DateFormatter.formatRelative(p.date),
                        trailingTitleColor: AppColors.deepForest,
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

  Widget _buildDetailRow(String label, String value, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 13,
                color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 13.5,
              fontWeight: FontWeight.w600,
              color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
            ),
          ),
        ],
      ),
    );
  }
}
