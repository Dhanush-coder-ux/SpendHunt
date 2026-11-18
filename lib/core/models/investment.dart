enum InvestmentType {
  stocks,
  mutualFunds,
  sip,
  gold,
  fixedDeposits,
  fixedDeposit,
  otherAssets,
}

extension InvestmentTypeExtension on InvestmentType {
  String get displayName {
    switch (this) {
      case InvestmentType.stocks:
        return 'Stocks';
      case InvestmentType.mutualFunds:
        return 'Mutual Funds';
      case InvestmentType.sip:
        return 'SIP';
      case InvestmentType.gold:
        return 'Digital Gold';
      case InvestmentType.fixedDeposits:
      case InvestmentType.fixedDeposit:
        return 'Fixed Deposits';
      case InvestmentType.otherAssets:
        return 'Other Assets';
    }
  }
}

class Investment {
  final String id;
  final String name;
  final InvestmentType type;
  final double investedAmount;
  final double currentValue;
  final DateTime purchaseDate;
  final double quantity;
  final String? symbol;
  final String? notes;

  Investment({
    required this.id,
    required this.name,
    required this.type,
    required this.investedAmount,
    required this.currentValue,
    required this.purchaseDate,
    this.quantity = 1,
    this.symbol,
    this.notes,
  });

  double get returnsAmount => currentValue - investedAmount;
  double get returns => returnsAmount;
  double get returnPercentage => investedAmount > 0 ? ((currentValue - investedAmount) / investedAmount) * 100 : 0.0;
  bool get isProfitable => returnsAmount >= 0;
  double get units => quantity;
  String? get identifier => symbol;
  DateTime get datePurchased => purchaseDate;

  Investment copyWith({
    String? id,
    String? name,
    InvestmentType? type,
    double? investedAmount,
    double? currentValue,
    DateTime? purchaseDate,
    double? quantity,
    String? symbol,
    String? notes,
  }) {
    return Investment(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      investedAmount: investedAmount ?? this.investedAmount,
      currentValue: currentValue ?? this.currentValue,
      purchaseDate: purchaseDate ?? this.purchaseDate,
      quantity: quantity ?? this.quantity,
      symbol: symbol ?? this.symbol,
      notes: notes ?? this.notes,
    );
  }
}
