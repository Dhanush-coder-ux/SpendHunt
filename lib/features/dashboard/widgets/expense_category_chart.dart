import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/models/transaction.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../shared/widgets/app_card.dart';

class ExpenseCategoryChart extends StatefulWidget {
  final List<TransactionModel> transactions;
  final String currency;

  const ExpenseCategoryChart({
    super.key,
    required this.transactions,
    this.currency = 'INR',
  });

  @override
  State<ExpenseCategoryChart> createState() => _ExpenseCategoryChartState();
}

class _ExpenseCategoryChartState extends State<ExpenseCategoryChart> {
  int _touchedIndex = -1;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Aggregate expenses by category
    final categoryTotals = <String, double>{};
    double totalExpense = 0.0;

    for (var tx in widget.transactions) {
      if (tx.type == TransactionType.expense) {
        categoryTotals[tx.categoryName] =
            (categoryTotals[tx.categoryName] ?? 0) + tx.amount;
        totalExpense += tx.amount;
      }
    }

    if (totalExpense == 0) {
      return const SizedBox.shrink();
    }

    // Sort categories descending
    final sorted = categoryTotals.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final topCategories = sorted.take(4).toList();

    // Map fixed earthy colors
    final colors = [
      AppColors.catFood,
      AppColors.catShopping,
      AppColors.catBills,
      AppColors.catTransport,
      AppColors.catOther,
    ];

    return AppCard(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Expense Breakdown',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                ),
              ),
              Text(
                CurrencyFormatter.format(totalExpense, currencyCode: widget.currency, compact: true),
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: isDark ? AppColors.textPrimaryDark : AppColors.deepForest,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          Row(
            children: [
              // Donut Chart
              SizedBox(
                width: 120,
                height: 120,
                child: PieChart(
                  PieChartData(
                    pieTouchData: PieTouchData(
                      touchCallback: (event, pieTouchResponse) {
                        setState(() {
                          if (!event.isInterestedForInteractions ||
                              pieTouchResponse == null ||
                              pieTouchResponse.touchedSection == null) {
                            _touchedIndex = -1;
                            return;
                          }
                          _touchedIndex = pieTouchResponse
                              .touchedSection!.touchedSectionIndex;
                        });
                      },
                    ),
                    sectionsSpace: 2,
                    centerSpaceRadius: 36,
                    sections: List.generate(topCategories.length, (i) {
                      final isTouched = i == _touchedIndex;
                      final double radius = isTouched ? 22 : 18;
                      final cat = topCategories[i];
                      final pct = (cat.value / totalExpense) * 100;

                      return PieChartSectionData(
                        color: colors[i % colors.length],
                        value: cat.value,
                        title: '',
                        radius: radius,
                        badgeWidget: isTouched
                            ? Container(
                                padding: const EdgeInsets.all(3),
                                decoration: BoxDecoration(
                                  color: Colors.black87,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  '${pct.toStringAsFixed(0)}%',
                                  style: const TextStyle(
                                    fontSize: 9,
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              )
                            : null,
                        badgePositionPercentageOffset: .98,
                      );
                    }),
                  ),
                ),
              ),
              const SizedBox(width: 20),

              // Breakdown List
              Expanded(
                child: Column(
                  children: List.generate(topCategories.length, (i) {
                    final cat = topCategories[i];
                    final pct = (cat.value / totalExpense) * 100;
                    final color = colors[i % colors.length];

                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 3.5),
                      child: Row(
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: color,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              cat.key,
                              style: TextStyle(
                                fontSize: 12.5,
                                color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                                fontWeight: FontWeight.w500,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Text(
                            '${pct.toStringAsFixed(0)}%',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textSecondaryLight,
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
