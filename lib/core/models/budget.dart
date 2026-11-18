enum BudgetPeriod {
  weekly,
  monthly,
  quarterly,
  yearly,
}

extension BudgetPeriodExtension on BudgetPeriod {
  String get displayName {
    switch (this) {
      case BudgetPeriod.weekly:
        return 'Weekly';
      case BudgetPeriod.monthly:
        return 'Monthly';
      case BudgetPeriod.quarterly:
        return 'Quarterly';
      case BudgetPeriod.yearly:
        return 'Yearly';
    }
  }
}

class Budget {
  final String id;
  final String name;
  final String categoryId;
  final String categoryName;
  final double amount;
  final BudgetPeriod period;
  final DateTime startDate;
  final DateTime endDate;
  final double alertThreshold; // 0.8 = 80%

  Budget({
    required this.id,
    required this.name,
    required this.categoryId,
    required this.categoryName,
    required this.amount,
    this.period = BudgetPeriod.monthly,
    required this.startDate,
    required this.endDate,
    this.alertThreshold = 0.8,
  });

  Budget copyWith({
    String? id,
    String? name,
    String? categoryId,
    String? categoryName,
    double? amount,
    BudgetPeriod? period,
    DateTime? startDate,
    DateTime? endDate,
    double? alertThreshold,
  }) {
    return Budget(
      id: id ?? this.id,
      name: name ?? this.name,
      categoryId: categoryId ?? this.categoryId,
      categoryName: categoryName ?? this.categoryName,
      amount: amount ?? this.amount,
      period: period ?? this.period,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      alertThreshold: alertThreshold ?? this.alertThreshold,
    );
  }
}
