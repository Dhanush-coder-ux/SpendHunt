import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../app/theme/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/providers/finance_provider.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../shared/widgets/confirmation_dialog.dart';
import '../../../shared/widgets/fin_animated_icon.dart';
import '../../../shared/widgets/fin_section.dart';
import '../../../shared/widgets/section_header.dart';

class InvestmentDetailsScreen extends ConsumerWidget {
  final String investmentId;

  const InvestmentDetailsScreen({super.key, required this.investmentId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final finance = ref.watch(financeProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final width = MediaQuery.of(context).size.width;
    final isDesktop = width >= AppConstants.tabletBreakpoint;

    final inv = finance.investments.where((i) => i.id == investmentId).firstOrNull;

    if (inv == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Investment Details')),
        body: const Center(child: Text('Investment holding not found')),
      );
    }

    final isProfit = inv.isProfitable;
    final returns = inv.returns;
    final returnRate = inv.returnPercentage;

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      appBar: AppBar(
        title: Text(inv.name, maxLines: 1, overflow: TextOverflow.ellipsis),
        actions: [
          IconButton(
            onPressed: () => context.push('/investments/add?editId=${inv.id}'),
            icon: const Icon(LucideIcons.pencil, size: 19),
            tooltip: 'Edit Holding',
          ),
          IconButton(
            onPressed: () async {
              final confirmed = await ConfirmationDialog.show(
                context,
                title: 'Delete Asset Holding',
                message: 'Are you sure you want to remove "${inv.name}" from your portfolio?',
              );
              if (confirmed == true && context.mounted) {
                ref.read(financeProvider.notifier).deleteInvestment(inv.id);
                context.pop();
              }
            },
            icon: const Icon(LucideIcons.trash2, size: 19, color: AppColors.error),
            tooltip: 'Delete Holding',
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
                // Top Valuation Section
                FinSection(
                  padding: const EdgeInsets.all(22),
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            inv.type.name.toUpperCase(),
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
                            color: (isProfit ? AppColors.success : AppColors.error).withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            '${isProfit ? "+" : ""}${returnRate.toStringAsFixed(1)}%',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: isProfit ? AppColors.success : AppColors.error,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      inv.name,
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
                      CurrencyFormatter.format(inv.currentValue, currencyCode: finance.profile.currency),
                      style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.8,
                        color: isDark ? AppColors.textPrimaryDark : AppColors.deepForest,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        FinAnimatedIcon(
                          icon: isProfit ? LucideIcons.trendingUp : LucideIcons.trendingDown,
                          size: 14,
                          color: isProfit ? AppColors.success : AppColors.error,
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            '${isProfit ? "+" : ""}${CurrencyFormatter.format(returns, currencyCode: finance.profile.currency)} total gains/loss',
                            style: TextStyle(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w600,
                              color: isProfit ? AppColors.success : AppColors.error,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Details Section
                const SectionHeader(title: 'Asset Holding Specifications'),
                const SizedBox(height: 10),

                FinSection(
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                  children: [
                    _buildDetailRow('Invested Capital', CurrencyFormatter.format(inv.investedAmount, currencyCode: finance.profile.currency), isDark),
                    const Divider(),
                    _buildDetailRow('Current Valuation', CurrencyFormatter.format(inv.currentValue, currencyCode: finance.profile.currency), isDark),
                    const Divider(),
                    _buildDetailRow('Asset Class', inv.type.name.toUpperCase(), isDark),
                    const Divider(),
                    _buildDetailRow('Quantity / Units', inv.units.toString(), isDark),
                    if (inv.identifier != null) ...[
                      const Divider(),
                      _buildDetailRow('Ticker / Identifier', inv.identifier!, isDark),
                    ],
                    const Divider(),
                    _buildDetailRow('Acquired On', DateFormatter.format(inv.datePurchased), isDark),
                    if (inv.notes != null && inv.notes!.isNotEmpty) ...[
                      const Divider(),
                      _buildDetailRow('Notes & Thesis', inv.notes!, isDark),
                    ],
                  ],
                ),
                const SizedBox(height: 20),

                // Simulated Disclaimer Badge
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.surfaceSecondaryDark : AppColors.surfaceSecondaryLight,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Row(
                    children: [
                      FinAnimatedIcon(icon: LucideIcons.info, size: 16, color: AppColors.textSecondaryLight),
                      SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Simulated mock market asset tracking only. Does not execute real stock/crypto market orders.',
                          style: TextStyle(fontSize: 11.5, color: AppColors.textSecondaryLight),
                        ),
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

  Widget _buildDetailRow(String label, String value, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 9),
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
