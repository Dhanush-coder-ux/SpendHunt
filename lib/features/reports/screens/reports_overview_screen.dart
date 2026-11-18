import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../app/theme/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/providers/finance_provider.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../shared/widgets/fin_animated_icon.dart';
import '../../../shared/widgets/fin_list_tile.dart';
import '../../../shared/widgets/fin_section.dart';
import '../../../shared/widgets/section_header.dart';

class ReportsOverviewScreen extends ConsumerStatefulWidget {
  const ReportsOverviewScreen({super.key});

  @override
  ConsumerState<ReportsOverviewScreen> createState() => _ReportsOverviewScreenState();
}

class _ReportsOverviewScreenState extends ConsumerState<ReportsOverviewScreen> {
  int _selectedFilter = 1; // 0: Weekly, 1: Monthly, 2: Quarterly, 3: Yearly

  @override
  Widget build(BuildContext context) {
    final finance = ref.watch(financeProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final width = MediaQuery.of(context).size.width;
    final isDesktop = width >= AppConstants.tabletBreakpoint;

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      appBar: AppBar(
        title: const Text('Financial Analytics & Reports', style: TextStyle(fontWeight: FontWeight.w700)),
        actions: [
          IconButton(
            onPressed: () => context.push('/reports/detailed'),
            icon: const Icon(LucideIcons.fileSpreadsheet, size: 20),
            tooltip: 'Detailed Analytics & Export',
          ),
          const SizedBox(width: 8),
        ],
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
              // Period Selector Tabs
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.surfaceSecondaryDark : AppColors.surfaceSecondaryLight,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    _buildTab('Weekly', 0, isDark),
                    _buildTab('Monthly', 1, isDark),
                    _buildTab('Quarterly', 2, isDark),
                    _buildTab('Yearly', 3, isDark),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Overview 3 Stat Cards
              Row(
                children: [
                  Expanded(
                    child: _buildMetricCard(
                      label: 'Total Inflow',
                      value: CurrencyFormatter.format(finance.totalIncomeThisMonth, currencyCode: finance.profile.currency, compact: true),
                      icon: LucideIcons.arrowDownLeft,
                      color: AppColors.success,
                      isDark: isDark,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _buildMetricCard(
                      label: 'Total Outflow',
                      value: CurrencyFormatter.format(finance.totalExpenseThisMonth, currencyCode: finance.profile.currency, compact: true),
                      icon: LucideIcons.arrowUpRight,
                      color: AppColors.warmBronze,
                      isDark: isDark,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _buildMetricCard(
                      label: 'Net Surplus',
                      value: CurrencyFormatter.format(finance.netSavingsThisMonth, currencyCode: finance.profile.currency, compact: true),
                      icon: LucideIcons.piggyBank,
                      color: AppColors.deepForest,
                      isDark: isDark,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 22),

              // Interactive Cash Flow Curve
              SectionHeader(
                title: 'Cash Flow Performance',
                actionLabel: 'Export Data',
                onAction: () => context.push('/reports/detailed'),
              ),
              const SizedBox(height: 10),

              FinSection(
                padding: const EdgeInsets.all(18),
                children: [
                  SizedBox(
                    height: 190,
                    child: LineChart(
                      LineChartData(
                        gridData: FlGridData(
                          show: true,
                          getDrawingHorizontalLine: (val) => FlLine(
                            color: (isDark ? AppColors.borderDark : AppColors.borderLight).withValues(alpha: 0.7),
                            strokeWidth: 0.8,
                            dashArray: [4, 4],
                          ),
                          drawVerticalLine: false,
                        ),
                        titlesData: FlTitlesData(
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              getTitlesWidget: (val, meta) {
                                const labels = ['W1', 'W2', 'W3', 'W4', 'W5'];
                                if (val.toInt() >= 0 && val.toInt() < labels.length) {
                                  return Padding(
                                    padding: const EdgeInsets.only(top: 8),
                                    child: Text(
                                      labels[val.toInt()],
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                                      ),
                                    ),
                                  );
                                }
                                return const SizedBox.shrink();
                              },
                            ),
                          ),
                          leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        ),
                        borderData: FlBorderData(show: false),
                        lineBarsData: [
                          LineChartBarData(
                            isCurved: true,
                            color: AppColors.success,
                            barWidth: 3,
                            dotData: const FlDotData(show: false),
                            spots: const [
                              FlSpot(0, 30),
                              FlSpot(1, 45),
                              FlSpot(2, 38),
                              FlSpot(3, 50),
                              FlSpot(4, 58),
                            ],
                          ),
                          LineChartBarData(
                            isCurved: true,
                            color: AppColors.warmBronze,
                            barWidth: 3,
                            dotData: const FlDotData(show: false),
                            spots: const [
                              FlSpot(0, 18),
                              FlSpot(1, 22),
                              FlSpot(2, 28),
                              FlSpot(3, 30),
                              FlSpot(4, 32),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildLegend(AppColors.success, 'Inflow (Income)'),
                      const SizedBox(width: 20),
                      _buildLegend(AppColors.warmBronze, 'Outflow (Expenses)'),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 22),

              // Report Cards Flat Section
              const SectionHeader(title: 'Standard Financial Statements'),
              const SizedBox(height: 10),

              FinSection(
                children: [
                  FinListTile(
                    onTap: () => context.push('/reports/detailed'),
                    leading: const FinAnimatedIcon(
                      icon: LucideIcons.fileSpreadsheet,
                      size: 19,
                      color: AppColors.deepForest,
                      backgroundColor: Color(0x1F0C3B2E),
                      backgroundSize: 40,
                      borderRadius: 12,
                    ),
                    title: 'Income Statement (P&L)',
                    subtitle: 'Detailed breakdown of active compensation, business, and dividends',
                    trailing: const Icon(LucideIcons.chevronRight, size: 18, color: AppColors.textSecondaryLight),
                    showDivider: true,
                  ),
                  FinListTile(
                    onTap: () => context.push('/reports/detailed'),
                    leading: const FinAnimatedIcon(
                      icon: LucideIcons.pieChart,
                      size: 19,
                      color: AppColors.warmBronze,
                      backgroundColor: Color(0x1FBB8A52),
                      backgroundSize: 40,
                      borderRadius: 12,
                    ),
                    title: 'Expense & Outflow Audit',
                    subtitle: 'Comprehensive ledger of category allocations, merchant run rates',
                    trailing: const Icon(LucideIcons.chevronRight, size: 18, color: AppColors.textSecondaryLight),
                    showDivider: true,
                  ),
                  FinListTile(
                    onTap: () => context.push('/reports/detailed'),
                    leading: const FinAnimatedIcon(
                      icon: LucideIcons.gem,
                      size: 19,
                      color: AppColors.success,
                      backgroundColor: Color(0x1F548B68),
                      backgroundSize: 40,
                      borderRadius: 12,
                    ),
                    title: 'Net Worth & Equity Position',
                    subtitle: 'Historical balance progression across cash, stocks, gold, and debt',
                    trailing: const Icon(LucideIcons.chevronRight, size: 18, color: AppColors.textSecondaryLight),
                    showDivider: false,
                  ),
                ],
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTab(String label, int index, bool isDark) {
    final isSelected = _selectedFilter == index;
    return Expanded(
      child: InkWell(
        onTap: () => setState(() => _selectedFilter = index),
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 7),
          decoration: BoxDecoration(
            color: isSelected ? (isDark ? AppColors.surfaceDark : Colors.white) : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                color: isSelected
                    ? (isDark ? Colors.white : AppColors.deepForest)
                    : (isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight),
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMetricCard({
    required String label,
    required String value,
    required IconData icon,
    required Color color,
    required bool isDark,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? AppColors.borderDark : AppColors.borderLight,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FinAnimatedIcon(
            icon: icon,
            size: 16,
            color: color,
            animateEntry: true,
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildLegend(Color color, String label) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(label, style: const TextStyle(fontSize: 11.5, color: AppColors.textSecondaryLight)),
      ],
    );
  }
}
