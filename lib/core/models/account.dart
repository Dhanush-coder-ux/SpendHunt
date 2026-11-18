enum AccountType {
  savings,
  current,
  creditCard,
  cash,
  digitalWallet,
}

extension AccountTypeExtension on AccountType {
  String get displayName {
    switch (this) {
      case AccountType.savings:
        return 'Savings Account';
      case AccountType.current:
        return 'Current Account';
      case AccountType.creditCard:
        return 'Credit Card';
      case AccountType.cash:
        return 'Cash';
      case AccountType.digitalWallet:
        return 'Digital Wallet';
    }
  }
}

class Account {
  final String id;
  final String name;
  final AccountType type;
  final double balance;
  final String lastFourDigits;
  final String currency;
  final String institution;
  final String? description;
  final DateTime createdAt;

  Account({
    required this.id,
    required this.name,
    required this.type,
    required this.balance,
    this.lastFourDigits = '0000',
    this.currency = 'INR',
    this.institution = 'FinPilot Bank',
    this.description,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Account copyWith({
    String? id,
    String? name,
    AccountType? type,
    double? balance,
    String? lastFourDigits,
    String? currency,
    String? institution,
    String? description,
    DateTime? createdAt,
  }) {
    return Account(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      balance: balance ?? this.balance,
      lastFourDigits: lastFourDigits ?? this.lastFourDigits,
      currency: currency ?? this.currency,
      institution: institution ?? this.institution,
      description: description ?? this.description,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
