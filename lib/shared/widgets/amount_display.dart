import 'package:flutter/material.dart';
import '../../core/utils/currency_formatter.dart';
import '../../app/theme/app_colors.dart';

class AmountDisplay extends StatelessWidget {
  final double amount;
  final String currencyCode;
  final double fontSize;
  final FontWeight fontWeight;
  final Color? color;
  final bool isExpense;
  final bool isIncome;
  final bool isMasked;
  final bool compact;
  final bool showDecimals;

  const AmountDisplay({
    super.key,
    required this.amount,
    this.currencyCode = 'INR',
    this.fontSize = 18.0,
    this.fontWeight = FontWeight.w600,
    this.color,
    this.isExpense = false,
    this.isIncome = false,
    this.isMasked = false,
    this.compact = false,
    this.showDecimals = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (isMasked) {
      return Text(
        '••••••',
        style: TextStyle(
          fontSize: fontSize,
          fontWeight: fontWeight,
          letterSpacing: 2,
          color: color ?? (isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight),
        ),
      );
    }

    Color effectiveColor = color ?? (isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight);
    String prefix = '';

    if (isIncome) {
      effectiveColor = AppColors.success;
      prefix = '+';
    } else if (isExpense) {
      effectiveColor = isDark ? AppColors.textPrimaryDark : AppColors.deepForest;
      prefix = '-';
    }

    final formatted = CurrencyFormatter.format(
      amount.abs(),
      currencyCode: currencyCode,
      compact: compact,
      showDecimals: showDecimals,
    );

    return Text(
      '$prefix$formatted',
      style: TextStyle(
        fontSize: fontSize,
        fontWeight: fontWeight,
        letterSpacing: -0.3,
        color: effectiveColor,
      ),
    );
  }
}
