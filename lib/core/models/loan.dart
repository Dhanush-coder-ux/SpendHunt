import 'dart:math';

enum LoanType {
  personal,
  vehicle,
  education,
  home,
  creditCard,
}

extension LoanTypeExtension on LoanType {
  String get displayName {
    switch (this) {
      case LoanType.personal:
        return 'Personal Loan';
      case LoanType.vehicle:
        return 'Vehicle Loan';
      case LoanType.education:
        return 'Education Loan';
      case LoanType.home:
        return 'Home Loan';
      case LoanType.creditCard:
        return 'Credit Card Debt';
    }
  }
}

class LoanPayment {
  final String id;
  final double amount;
  final double principalPaid;
  final double interestPaid;
  final DateTime date;

  LoanPayment({
    required this.id,
    required this.amount,
    required this.principalPaid,
    required this.interestPaid,
    required this.date,
  });
}

class Loan {
  final String id;
  final String name;
  final LoanType type;
  final double principalAmount;
  final double outstandingBalance;
  final double annualInterestRate; // in % e.g. 10.5
  final int tenureMonths;
  final DateTime startDate;
  final double monthlyEmi;
  final DateTime nextPaymentDate;
  final String lender;
  final List<LoanPayment> payments;

  Loan({
    required this.id,
    required this.name,
    required this.type,
    required this.principalAmount,
    required this.outstandingBalance,
    required this.annualInterestRate,
    required this.tenureMonths,
    required this.startDate,
    required this.monthlyEmi,
    required this.nextPaymentDate,
    this.lender = 'HDFC Bank',
    List<LoanPayment>? payments,
  }) : payments = payments ?? [];

  double get paidAmount => (principalAmount - outstandingBalance).clamp(0, double.infinity);
  double get repaymentProgress => principalAmount > 0 ? (paidAmount / principalAmount).clamp(0.0, 1.0) : 0.0;

  static double calculateEmi({
    required double principal,
    required double annualRate,
    required int tenureMonths,
  }) {
    if (principal <= 0 || tenureMonths <= 0) return 0;
    if (annualRate <= 0) return principal / tenureMonths;

    final monthlyRate = annualRate / 12 / 100;
    final emi = (principal * monthlyRate * pow(1 + monthlyRate, tenureMonths)) /
        (pow(1 + monthlyRate, tenureMonths) - 1);
    return emi;
  }

  Loan copyWith({
    String? id,
    String? name,
    LoanType? type,
    double? principalAmount,
    double? outstandingBalance,
    double? annualInterestRate,
    int? tenureMonths,
    DateTime? startDate,
    double? monthlyEmi,
    DateTime? nextPaymentDate,
    String? lender,
    List<LoanPayment>? payments,
  }) {
    return Loan(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      principalAmount: principalAmount ?? this.principalAmount,
      outstandingBalance: outstandingBalance ?? this.outstandingBalance,
      annualInterestRate: annualInterestRate ?? this.annualInterestRate,
      tenureMonths: tenureMonths ?? this.tenureMonths,
      startDate: startDate ?? this.startDate,
      monthlyEmi: monthlyEmi ?? this.monthlyEmi,
      nextPaymentDate: nextPaymentDate ?? this.nextPaymentDate,
      lender: lender ?? this.lender,
      payments: payments ?? this.payments,
    );
  }
}
