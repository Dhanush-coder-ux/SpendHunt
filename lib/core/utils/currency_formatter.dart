import 'package:intl/intl.dart';

class CurrencyFormatter {
  static String format(
    double amount, {
    String currencyCode = 'INR',
    bool showDecimals = false,
    bool compact = false,
  }) {
    final symbol = getSymbol(currencyCode);

    if (compact) {
      if (amount.abs() >= 10000000) {
        return '$symbol${(amount / 10000000).toStringAsFixed(2)} Cr';
      } else if (amount.abs() >= 100000) {
        return '$symbol${(amount / 100000).toStringAsFixed(2)} L';
      } else if (amount.abs() >= 1000) {
        return '$symbol${(amount / 1000).toStringAsFixed(1)}k';
      }
    }

    final formatPattern = showDecimals ? '#,##,##0.00' : '#,##,##0';
    final numberFormat = NumberFormat(formatPattern, 'en_IN');
    return '$symbol${numberFormat.format(amount)}';
  }

  static String getSymbol(String currencyCode) {
    switch (currencyCode.toUpperCase()) {
      case 'INR':
        return '₹';
      case 'USD':
        return '\$';
      case 'EUR':
        return '€';
      case 'GBP':
        return '£';
      case 'AED':
        return 'AED ';
      case 'JPY':
        return '¥';
      default:
        return '₹';
    }
  }
}
