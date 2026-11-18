import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../app/theme/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/models/loan.dart';
import '../../../core/providers/finance_provider.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../../shared/widgets/fin_animated_icon.dart';
import '../../../shared/widgets/fin_section.dart';

class LoansScreen extends ConsumerWidget {
  const LoansScreen({super.key});

  IconData _getLoanIcon(LoanType type) {
    switch (type) {
      case LoanType.vehicle:
        return LucideIcons.car;
      case LoanType.education:
        return LucideIcons.graduationCap;
      case LoanType.home:
        return LucideIcons.house;
      case LoanType.creditCard:
        return LucideIcons.creditCard;
      case LoanType.personal:
        return LucideIcons.user;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final finance = ref.watch(financeProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final width = MediaQuery.of(context).size.width;
    final isDesktop = width >= AppConstants.tabletBreakpoint;

    final totalDebt = finance.totalOutstandingDebt;
    final totalEmi = finance.totalMonthlyEmi;

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      appBar: AppBar(
        title: const Text('Loans & EMI', style: TextStyle(fontWeight: FontWeight.w700)),
        actions: [
          IconButton(
            onPressed: () => context.push('/loans/add'),
            icon: const Icon(LucideIcons.plus, size: 20),
            tooltip: 'Add Loan',
          ),
          const SizedBox(width: 8),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/loans/add'),
        backgroundColor: AppColors.deepForest,
        foregroundColor: Colors.white,
        icon: const Icon(LucideIcons.plus, size: 18),
        label: const Text('Add Loan', style: TextStyle(fontWeight: FontWeight.w600)),
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
              // Hero Debt Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.surfaceDark : AppColors.deepForest,
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
                            'TOTAL OUTSTANDING LIABILITIES',
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
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            '${finance.loans.length} Active Loans',
                            style: const TextStyle(fontSize: 11, color: Colors.white70, fontWeight: FontWeight.w600),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      CurrencyFormatter.format(totalDebt, currencyCode: finance.profile.currency),
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.8,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(height: 1, color: Colors.white.withValues(alpha: 0.12)),
                    const SizedBox(height: 14),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Monthly EMI Commitment',
                                style: TextStyle(fontSize: 11.5, color: Colors.white.withValues(alpha: 0.7)),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 2),
                              Text(
                                CurrencyFormatter.format(totalEmi, currencyCode: finance.profile.currency),
                                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.goldenYellow),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              'Debt-to-Income',
                              style: TextStyle(fontSize: 11.5, color: Colors.white.withValues(alpha: 0.7)),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '${((totalEmi / (finance.profile.monthlyIncome > 0 ? finance.profile.monthlyIncome : 1)) * 100).toStringAsFixed(1)}%',
                              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Colors.white),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              Text(
                'ACTIVE LOANS & LIABILITIES',
                style: TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.8,
                  color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                ),
              ),
              const SizedBox(height: 12),

              if (finance.loans.isEmpty)
                EmptyState(
                  title: 'No active liabilities',
                  description: 'Track personal loans, vehicle financing, mortgages and student debts.',
                  icon: LucideIcons.badgeCheck,
                  actionLabel: 'Add Liability',
                  onAction: () => context.push('/loans/add'),
                )
              else
                FinSection(
                  children: List.generate(finance.loans.length, (index) {
                    final loan = finance.loans[index];
                    final isLast = index == finance.loans.length - 1;
                    return _buildLoanRow(context, loan, finance.profile.currency, isDark, !isLast);
                  }),
                ),
              const SizedBox(height: 60),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLoanRow(
    BuildContext context,
    Loan loan,
    String currency,
    bool isDark,
    bool showDivider,
  ) {
    final progress = loan.repaymentProgress;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => context.push('/loans/details/${loan.id}'),
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
                        icon: _getLoanIcon(loan.type),
                        size: 18,
                        color: AppColors.warmBronze,
                        backgroundColor: AppColors.warmBronze.withValues(alpha: 0.12),
                        backgroundSize: 38,
                        borderRadius: 10,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              loan.name,
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
                              '${loan.lender} • ${loan.annualInterestRate}% p.a.',
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
                      const SizedBox(width: 10),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: isDark ? AppColors.surfaceSecondaryDark : AppColors.surfaceSecondaryLight,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          '${(progress * 100).toStringAsFixed(0)}% Paid',
                          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
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
                      valueColor: const AlwaysStoppedAnimation<Color>(AppColors.deepForest),
                      minHeight: 6,
                    ),
                  ),
                  const SizedBox(height: 10),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Outstanding Balance', style: TextStyle(fontSize: 11, color: AppColors.textSecondaryLight)),
                            const SizedBox(height: 2),
                            Text(
                              CurrencyFormatter.format(loan.outstandingBalance, currencyCode: currency),
                              style: TextStyle(
                                fontSize: 13.5,
                                fontWeight: FontWeight.w700,
                                color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
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
                          const Text('Monthly EMI', style: TextStyle(fontSize: 11, color: AppColors.textSecondaryLight)),
                          const SizedBox(height: 2),
                          Text(
                            CurrencyFormatter.format(loan.monthlyEmi, currencyCode: currency),
                            style: const TextStyle(
                              fontSize: 13.5,
                              fontWeight: FontWeight.w700,
                              color: AppColors.warmBronze,
                            ),
                          ),
                        ],
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
