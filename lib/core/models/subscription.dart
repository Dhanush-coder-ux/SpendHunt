enum BillingCycle {
  monthly,
  quarterly,
  yearly,
}

extension BillingCycleExtension on BillingCycle {
  String get displayName {
    switch (this) {
      case BillingCycle.monthly:
        return 'Monthly';
      case BillingCycle.quarterly:
        return 'Quarterly';
      case BillingCycle.yearly:
        return 'Yearly';
    }
  }
}

enum SubscriptionStatus {
  active,
  cancelled,
  overdue,
}

class Subscription {
  final String id;
  final String name;
  final double amount;
  final BillingCycle cycle;
  final DateTime nextBillingDate;
  final String category;
  final String accountId;
  final String accountName;
  final SubscriptionStatus status;
  final String iconName;

  Subscription({
    required this.id,
    required this.name,
    required this.amount,
    required this.cycle,
    required this.nextBillingDate,
    required this.category,
    required this.accountId,
    required this.accountName,
    this.status = SubscriptionStatus.active,
    this.iconName = 'subscription',
  });

  BillingCycle get billingCycle => cycle;
  String get categoryName => category;

  Subscription copyWith({
    String? id,
    String? name,
    double? amount,
    BillingCycle? cycle,
    DateTime? nextBillingDate,
    String? category,
    String? accountId,
    String? accountName,
    SubscriptionStatus? status,
    String? iconName,
  }) {
    return Subscription(
      id: id ?? this.id,
      name: name ?? this.name,
      amount: amount ?? this.amount,
      cycle: cycle ?? this.cycle,
      nextBillingDate: nextBillingDate ?? this.nextBillingDate,
      category: category ?? this.category,
      accountId: accountId ?? this.accountId,
      accountName: accountName ?? this.accountName,
      status: status ?? this.status,
      iconName: iconName ?? this.iconName,
    );
  }
}
