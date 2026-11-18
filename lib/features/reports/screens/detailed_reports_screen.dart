import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../app/theme/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/providers/finance_provider.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/fin_section.dart';
import '../../../shared/widgets/section_header.dart';

class DetailedReportsScreen extends ConsumerStatefulWidget {
  const DetailedReportsScreen({super.key});

  @override
  ConsumerState<DetailedReportsScreen> createState() => _DetailedReportsScreenState();
}

class _DetailedReportsScreenState extends ConsumerState<DetailedReportsScreen> {
  bool _isExporting = false;

  void _exportReport(String format) {
    setState(() => _isExporting = true);
    Future.delayed(const Duration(milliseconds: 1000), () {
      if (mounted) {
        setState(() => _isExporting = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('SpendHunt_Financial_Report_${DateTime.now().year}_Q4.$format downloaded successfully!'),
            backgroundColor: AppColors.deepForest,
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final finance = ref.watch(financeProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final width = MediaQuery.of(context).size.width;
    final isDesktop = width >= AppConstants.tabletBreakpoint;

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      appBar: AppBar(
        title: const Text('Detailed Financial Analysis'),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? AppColors.surfaceDark : Colors.white,
          border: Border(top: BorderSide(color: (isDark ? AppColors.borderDark : AppColors.borderLight).withValues(alpha: 0.8))),
        ),
        child: SafeArea(
          child: Row(
            children: [
              Expanded(
                child: AppButton(
                  label: 'Export PDF Report',
                  icon: LucideIcons.fileText,
                  isLoading: _isExporting,
                  onPressed: () => _exportReport('pdf'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: AppButton(
                  label: 'Export CSV Data',
                  icon: LucideIcons.fileSpreadsheet,
                  variant: AppButtonVariant.outlined,
                  onPressed: () => _exportReport('csv'),
                ),
              ),
            ],
          ),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 780),
            child: ListView(
              padding: EdgeInsets.symmetric(
                horizontal: isDesktop ? 32 : 18,
                vertical: 18,
              ),
              children: [
                // Executive Overview
                FinSection(
                  padding: const EdgeInsets.all(20),
                  children: [
                    const Text(
                      'EXECUTIVE AUDIT SUMMARY',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.8,
                        color: AppColors.warmBronze,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Net Worth: ${CurrencyFormatter.format(finance.netWorth, currencyCode: finance.profile.currency)}',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: isDark ? AppColors.textPrimaryDark : AppColors.deepForest,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Total Liquid & Investment Capital: ${CurrencyFormatter.format(finance.totalBalance + finance.totalInvestmentValue, currencyCode: finance.profile.currency)} with liabilities of ${CurrencyFormatter.format(finance.totalOutstandingDebt, currencyCode: finance.profile.currency)}.',
                      style: TextStyle(
                        fontSize: 13,
                        color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Table: Income vs Expense Breakdown
                const SectionHeader(
                  title: 'Comparative Cash Flow Summary',
                  subtitle: 'Inflow vs Outflows by key category drivers',
                ),
                const SizedBox(height: 10),

                FinSection(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  children: [
                    _buildRow('Primary Salary Inflow', '+₹1,45,000', AppColors.success, true),
                    const Divider(),
                    _buildRow('Freelance & Consulting', '+₹35,000', AppColors.success, true),
                    const Divider(),
                    _buildRow('Dividends & Investments', '+₹3,200', AppColors.success, true),
                    const Divider(),
                    _buildRow('Living & Groceries Outflow', '-₹3,450', AppColors.warmBronze, false),
                    const Divider(),
                    _buildRow('Shopping & Retail', '-₹6,990', AppColors.warmBronze, false),
                    const Divider(),
                    _buildRow('Utilities & Recurring', '-₹1,179', AppColors.warmBronze, false),
                    const Divider(),
                    _buildRow('Mutual Fund SIP Investment', '-₹25,000', AppColors.deepForest, false),
                  ],
                ),
                const SizedBox(height: 22),

                // Net Worth & Reserve History
                const SectionHeader(
                  title: 'Net Equity Position Over Time',
                  subtitle: 'Simulated 6-month trailing wealth trajectory',
                ),
                const SizedBox(height: 10),

                FinSection(
                  padding: const EdgeInsets.all(16),
                  children: [
                    _buildHistoryRow('November (Current)', finance.netWorth, '+8.4%'),
                    const Divider(),
                    _buildHistoryRow('October', finance.netWorth * 0.94, '+6.1%'),
                    const Divider(),
                    _buildHistoryRow('September', finance.netWorth * 0.89, '+5.4%'),
                    const Divider(),
                    _buildHistoryRow('August', finance.netWorth * 0.84, '+4.8%'),
                  ],
                ),
                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRow(String title, String amount, Color color, bool isPositive) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              title,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            amount,
            style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w700, color: color),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryRow(String month, double amount, String growth) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              month,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 8),
          Row(
            children: [
              Text(
                CurrencyFormatter.format(amount, compact: true),
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
              ),
              const SizedBox(width: 8),
              Text(
                growth,
                style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600, color: AppColors.success),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
