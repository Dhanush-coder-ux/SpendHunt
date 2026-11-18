enum TransactionType {
  expense,
  income,
  transfer,
}

extension TransactionTypeExtension on TransactionType {
  String get displayName {
    switch (this) {
      case TransactionType.expense:
        return 'Expense';
      case TransactionType.income:
        return 'Income';
      case TransactionType.transfer:
        return 'Transfer';
    }
  }
}

class TransactionModel {
  final String id;
  final String title;
  final double amount;
  final TransactionType type;
  final String categoryId;
  final String categoryName;
  final String accountId;
  final String accountName;
  final String? destinationAccountId;
  final String? destinationAccountName;
  final DateTime date;
  final String paymentMethod;
  final String? notes;
  final String? receiptPath;
  final String merchant;

  TransactionModel({
    required this.id,
    required this.title,
    required this.amount,
    required this.type,
    required this.categoryId,
    required this.categoryName,
    required this.accountId,
    required this.accountName,
    this.destinationAccountId,
    this.destinationAccountName,
    required this.date,
    this.paymentMethod = 'Bank Transfer',
    this.notes,
    this.receiptPath,
    String? merchant,
  }) : merchant = merchant ?? title;

  TransactionModel copyWith({
    String? id,
    String? title,
    double? amount,
    TransactionType? type,
    String? categoryId,
    String? categoryName,
    String? accountId,
    String? accountName,
    String? destinationAccountId,
    String? destinationAccountName,
    DateTime? date,
    String? paymentMethod,
    String? notes,
    String? receiptPath,
    String? merchant,
  }) {
    return TransactionModel(
      id: id ?? this.id,
      title: title ?? this.title,
      amount: amount ?? this.amount,
      type: type ?? this.type,
      categoryId: categoryId ?? this.categoryId,
      categoryName: categoryName ?? this.categoryName,
      accountId: accountId ?? this.accountId,
      accountName: accountName ?? this.accountName,
      destinationAccountId: destinationAccountId ?? this.destinationAccountId,
      destinationAccountName: destinationAccountName ?? this.destinationAccountName,
      date: date ?? this.date,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      notes: notes ?? this.notes,
      receiptPath: receiptPath ?? this.receiptPath,
      merchant: merchant ?? this.merchant,
    );
  }
}
