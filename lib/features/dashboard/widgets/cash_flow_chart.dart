import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../shared/widgets/app_card.dart';

class CashFlowChart extends StatefulWidget {
  final double? income;
  final double? expense;
  final String currency;
  final List<dynamic>? transactions;

  const CashFlowChart({
    super.key,
    this.income,
    this.expense,
    this.currency = 'INR',
    this.transactions,
  });

  @override
  State<CashFlowChart> createState() => _CashFlowChartState();
}

class _CashFlowChartState extends State<CashFlowChart> {
  int _selectedPeriodIndex = 0; // 0: Weekly, 1: Monthly

  double get _effectiveIncome => widget.income ?? 0.0;
  double get _effectiveExpense => widget.expense ?? 0.0;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AppCard(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Cash Flow Activity',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Income vs Outflow trends',
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.all(3),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.surfaceSecondaryDark : AppColors.surfaceSecondaryLight,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    _buildToggleItem('Weekly', 0, isDark),
                    _buildToggleItem('Monthly', 1, isDark),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Legend
          Row(
            children: [
              _buildLegend(AppColors.deepForest, 'Income'),
              const SizedBox(width: 16),
              _buildLegend(AppColors.warmBronze, 'Expense'),
              const Spacer(),
              Text(
                'Net: +${CurrencyFormatter.format((_effectiveIncome - _effectiveExpense).clamp(0, double.infinity), currencyCode: widget.currency, compact: true)}',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.success,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Chart
          SizedBox(
            height: 170,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: 60,
                barTouchData: BarTouchData(
                  touchTooltipData: BarTouchTooltipData(
                    getTooltipColor: (_) => isDark ? AppColors.surfaceDark : AppColors.deepForest,
                    getTooltipItem: (group, groupIndex, rod, rodIndex) {
                      final isIncome = rodIndex == 0;
                      return BarTooltipItem(
                        '${isIncome ? "Income" : "Expense"}\n₹${rod.toY.toInt()}k',
                        const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 11,
                        ),
                      );
                    },
                  ),
                ),
                titlesData: FlTitlesData(
                  show: true,
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (val, meta) {
                        const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
                        const months = ['Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec', 'Nov*'];
                        final labels = _selectedPeriodIndex == 0 ? days : months;
                        final idx = val.toInt();
                        if (idx >= 0 && idx < labels.length) {
                          return Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text(
                              labels[idx],
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
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  getDrawingHorizontalLine: (value) => FlLine(
                    color: (isDark ? AppColors.borderDark : AppColors.borderLight).withValues(alpha: 0.7),
                    strokeWidth: 0.8,
                    dashArray: [4, 4],
                  ),
                ),
                borderData: FlBorderData(show: false),
                barGroups: _generateBarGroups(isDark),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildToggleItem(String label, int index, bool isDark) {
    final isSelected = _selectedPeriodIndex == index;
    return InkWell(
      onTap: () => setState(() => _selectedPeriodIndex = index),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: isSelected
              ? (isDark ? AppColors.deepForest : Colors.white)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 4,
                  )
                ]
              : null,
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11.5,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
            color: isSelected
                ? (isDark ? Colors.white : AppColors.deepForest)
                : (isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight),
          ),
        ),
      ),
    );
  }

  Widget _buildLegend(Color color, String label) {
    return Row(
      children: [
        Container(
          width: 9,
          height: 9,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: AppColors.textSecondaryLight,
          ),
        ),
      ],
    );
  }

  List<BarChartGroupData> _generateBarGroups(bool isDark) {
    final incomeColor = isDark ? AppColors.sage : AppColors.deepForest;
    const expenseColor = AppColors.warmBronze;

    final data = _selectedPeriodIndex == 0
        ? [
            [28.0, 14.0],
            [12.0, 8.0],
            [45.0, 18.0],
            [18.0, 22.0],
            [35.0, 12.0],
            [50.0, 32.0],
            [22.0, 16.0],
          ]
        : [
            [38.0, 26.0],
            [42.0, 30.0],
            [48.0, 34.0],
            [45.0, 29.0],
            [52.0, 35.0],
            [55.0, 38.0],
            [49.0, 31.0],
          ];

    return List.generate(data.length, (i) {
      return BarChartGroupData(
        x: i,
        barsSpace: 4,
        barRods: [
          BarChartRodData(
            toY: data[i][0],
            color: incomeColor,
            width: 7,
            borderRadius: BorderRadius.circular(3),
          ),
          BarChartRodData(
            toY: data[i][1],
            color: expenseColor,
            width: 7,
            borderRadius: BorderRadius.circular(3),
          ),
        ],
      );
    });
  }
}
