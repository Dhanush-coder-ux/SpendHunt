import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../app/theme/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/providers/finance_provider.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../shared/widgets/fin_section.dart';
import '../../../shared/widgets/section_header.dart';

class AIForecastScreen extends ConsumerStatefulWidget {
  const AIForecastScreen({super.key});

  @override
  ConsumerState<AIForecastScreen> createState() => _AIForecastScreenState();
}

class _AIForecastScreenState extends ConsumerState<AIForecastScreen> {
  double _shoppingCutPercentage = 20.0; // 20%

  @override
  Widget build(BuildContext context) {
    final finance = ref.watch(financeProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final width = MediaQuery.of(context).size.width;
    final isDesktop = width >= AppConstants.tabletBreakpoint;

    final currentSpend = finance.totalExpenseThisMonth;
    final projectedSpend = currentSpend * 1.15; // Extrapolated run rate
    final income = finance.totalIncomeThisMonth;
    final projectedSavings = income - projectedSpend;

    // Simulation calculation
    final shoppingSpend = finance.getSpentForCategory('cat_shopping');
    final simulatedSavingsGain = shoppingSpend * (_shoppingCutPercentage / 100);
    final adjustedProjectedSavings = projectedSavings + simulatedSavingsGain;

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      appBar: AppBar(
        title: const Text('AI Financial Forecast'),
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 760),
            child: ListView(
              padding: EdgeInsets.symmetric(
                horizontal: isDesktop ? 32 : 18,
                vertical: 18,
              ),
              children: [
                // Forecast Summary Hero
                Container(
                  padding: const EdgeInsets.all(22),
                  decoration: BoxDecoration(
                    color: AppColors.deepForest,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'END-OF-MONTH CASH FLOW FORECAST',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.8,
                              color: AppColors.goldenYellow,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Text('Illustrative Model', style: TextStyle(fontSize: 10, color: Colors.white70)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Projected Total Outflow: ${CurrencyFormatter.format(projectedSpend, currencyCode: finance.profile.currency)}',
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Expected Month-End Surplus: ${CurrencyFormatter.format(projectedSavings, currencyCode: finance.profile.currency)}',
                        style: const TextStyle(
                          fontSize: 14.5,
                          fontWeight: FontWeight.w600,
                          color: AppColors.goldenYellow,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 22),

                // Cash Flow Projection Graph
                const SectionHeader(
                  title: 'Cumulative Run-Rate Trajectory',
                  subtitle: 'Historical baseline vs projected daily accumulation',
                ),
                const SizedBox(height: 12),

                FinSection(
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    children: [
                      SizedBox(
                        height: 180,
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
                                    const labels = ['Day 1', 'Day 8', 'Day 15', 'Day 22', 'Day 30'];
                                    final i = val.toInt();
                                    if (i >= 0 && i < labels.length) {
                                      return Padding(
                                        padding: const EdgeInsets.only(top: 8.0),
                                        child: Text(
                                          labels[i],
                                          style: TextStyle(
                                            fontSize: 10.5,
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
                                color: isDark ? AppColors.sage : AppColors.deepForest,
                                barWidth: 3,
                                dotData: const FlDotData(show: false),
                                spots: const [
                                  FlSpot(0, 5),
                                  FlSpot(1, 14),
                                  FlSpot(2, 28),
                                  FlSpot(3, 42),
                                  FlSpot(4, 52),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        'Projection indicates steady cash flow surplus within healthy safety margins.',
                        style: TextStyle(fontSize: 11.5, color: AppColors.textSecondaryLight),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 22),

                // Interactive Scenario Simulation
                const SectionHeader(
                  title: 'Scenario Simulation Engine',
                  subtitle: 'Simulate changes in discretionary spending habits',
                ),
                const SizedBox(height: 12),

                FinSection(
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Expanded(
                            child: Text(
                              'What if I reduce Shopping expenses by:',
                              style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w600),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '${_shoppingCutPercentage.toInt()}%',
                            style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: AppColors.warmBronze),
                          ),
                        ],
                      ),
                      Slider(
                        value: _shoppingCutPercentage,
                        min: 0,
                        max: 60,
                        divisions: 12,
                        activeColor: AppColors.deepForest,
                        onChanged: (val) => setState(() => _shoppingCutPercentage = val),
                      ),
                      const SizedBox(height: 10),
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: isDark ? AppColors.surfaceSecondaryDark : AppColors.surfaceSecondaryLight,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                const Expanded(
                                  child: Text('Additional Monthly Savings:', style: TextStyle(fontSize: 12.5)),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  '+${CurrencyFormatter.format(simulatedSavingsGain, currencyCode: finance.profile.currency)}',
                                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.success),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                const Expanded(
                                  child: Text('New Projected Month-End Surplus:', style: TextStyle(fontSize: 12.5)),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  CurrencyFormatter.format(adjustedProjectedSavings, currencyCode: finance.profile.currency),
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                    color: isDark ? AppColors.textPrimaryDark : AppColors.deepForest,
                                  ),
                                ),
                              ],
                            ),
                          ],
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
}
