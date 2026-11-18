import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/account.dart';
import '../models/transaction.dart';
import '../models/budget.dart';
import '../models/savings_goal.dart';
import '../models/investment.dart';
import '../models/loan.dart';
import '../models/subscription.dart';
import '../models/category_item.dart';
import '../models/user_profile.dart';
import '../mock_data/initial_data.dart';

class FinanceState {
  final List<Account> accounts;
  final List<TransactionModel> transactions;
  final List<CategoryItem> categories;
  final List<Budget> budgets;
  final List<SavingsGoal> savingsGoals;
  final List<Investment> investments;
  final List<Loan> loans;
  final List<Subscription> subscriptions;
  final UserProfile profile;

  FinanceState({
    required this.accounts,
    required this.transactions,
    required this.categories,
    required this.budgets,
    required this.savingsGoals,
    required this.investments,
    required this.loans,
    required this.subscriptions,
    required this.profile,
  });

  FinanceState copyWith({
    List<Account>? accounts,
    List<TransactionModel>? transactions,
    List<CategoryItem>? categories,
    List<Budget>? budgets,
    List<SavingsGoal>? savingsGoals,
    List<Investment>? investments,
    List<Loan>? loans,
    List<Subscription>? subscriptions,
    UserProfile? profile,
  }) {
    return FinanceState(
      accounts: accounts ?? this.accounts,
      transactions: transactions ?? this.transactions,
      categories: categories ?? this.categories,
      budgets: budgets ?? this.budgets,
      savingsGoals: savingsGoals ?? this.savingsGoals,
      investments: investments ?? this.investments,
      loans: loans ?? this.loans,
      subscriptions: subscriptions ?? this.subscriptions,
      profile: profile ?? this.profile,
    );
  }

  // Reactive financial calculations
  double get totalBalance {
    double total = 0.0;
    for (var acc in accounts) {
      total += acc.balance;
    }
    return total;
  }

  double get totalIncomeThisMonth {
    final now = DateTime.now();
    double total = 0.0;
    for (var tx in transactions) {
      if (tx.type == TransactionType.income &&
          tx.date.year == now.year &&
          tx.date.month == now.month) {
        total += tx.amount;
      }
    }
    return total;
  }

  double get totalExpenseThisMonth {
    final now = DateTime.now();
    double total = 0.0;
    for (var tx in transactions) {
      if (tx.type == TransactionType.expense &&
          tx.date.year == now.year &&
          tx.date.month == now.month) {
        total += tx.amount;
      }
    }
    return total;
  }

  double get netSavingsThisMonth => totalIncomeThisMonth - totalExpenseThisMonth;

  double get savingsRateThisMonth {
    if (totalIncomeThisMonth <= 0) return 0.0;
    return (netSavingsThisMonth / totalIncomeThisMonth) * 100;
  }

  double get totalInvestmentValue {
    double total = 0.0;
    for (var inv in investments) {
      total += inv.currentValue;
    }
    return total;
  }

  double get totalInvestedCost {
    double total = 0.0;
    for (var inv in investments) {
      total += inv.investedAmount;
    }
    return total;
  }

  double get totalInvestedCapital => totalInvestedCost;

  double get totalInvestmentReturns => totalInvestmentValue - totalInvestedCost;

  double get totalInvestmentReturnRate {
    if (totalInvestedCost <= 0) return 0.0;
    return (totalInvestmentReturns / totalInvestedCost) * 100;
  }

  double get totalOutstandingDebt {
    double total = 0.0;
    for (var loan in loans) {
      total += loan.outstandingBalance;
    }
    for (var acc in accounts) {
      if (acc.balance < 0) {
        total += acc.balance.abs();
      }
    }
    return total;
  }

  double get totalMonthlyEmi {
    double total = 0.0;
    for (var loan in loans) {
      total += loan.monthlyEmi;
    }
    return total;
  }

  double get totalMonthlySubscriptions {
    double total = 0.0;
    for (var sub in subscriptions) {
      if (sub.status == SubscriptionStatus.active) {
        if (sub.cycle == BillingCycle.monthly) {
          total += sub.amount;
        } else if (sub.cycle == BillingCycle.yearly) {
          total += (sub.amount / 12);
        } else if (sub.cycle == BillingCycle.quarterly) {
          total += (sub.amount / 3);
        }
      }
    }
    return total;
  }

  double get netWorth => (totalBalance + totalInvestmentValue) - totalOutstandingDebt;

  double getSpentForCategory(String categoryId) {
    final now = DateTime.now();
    double total = 0.0;
    for (var tx in transactions) {
      if (tx.type == TransactionType.expense &&
          tx.categoryId == categoryId &&
          tx.date.year == now.year &&
          tx.date.month == now.month) {
        total += tx.amount;
      }
    }
    return total;
  }

  double get totalBudgetAmount {
    double total = 0.0;
    for (var b in budgets) {
      total += b.amount;
    }
    return total;
  }

  double get totalBudgetSpent {
    double total = 0.0;
    for (var b in budgets) {
      total += getSpentForCategory(b.categoryId);
    }
    return total;
  }
}

class FinanceNotifier extends StateNotifier<FinanceState> {
  FinanceNotifier()
      : super(
          FinanceState(
            accounts: InitialData.accounts,
            transactions: InitialData.transactions,
            categories: InitialData.categories,
            budgets: InitialData.budgets,
            savingsGoals: InitialData.savingsGoals,
            investments: InitialData.investments,
            loans: InitialData.loans,
            subscriptions: InitialData.subscriptions,
            profile: const UserProfile(),
          ),
        );

  // Transaction CRUD
  void addTransaction(TransactionModel tx) {
    final updatedTxs = [tx, ...state.transactions];

    // Update account balances reactively
    final updatedAccounts = state.accounts.map((acc) {
      if (tx.type == TransactionType.income && acc.id == tx.accountId) {
        return acc.copyWith(balance: acc.balance + tx.amount);
      } else if (tx.type == TransactionType.expense && acc.id == tx.accountId) {
        return acc.copyWith(balance: acc.balance - tx.amount);
      } else if (tx.type == TransactionType.transfer) {
        if (acc.id == tx.accountId) {
          return acc.copyWith(balance: acc.balance - tx.amount);
        } else if (acc.id == tx.destinationAccountId) {
          return acc.copyWith(balance: acc.balance + tx.amount);
        }
      }
      return acc;
    }).toList();

    state = state.copyWith(
      transactions: updatedTxs,
      accounts: updatedAccounts,
    );
  }

  void updateTransaction(TransactionModel tx) {
    final oldTxIndex = state.transactions.indexWhere((t) => t.id == tx.id);
    if (oldTxIndex == -1) return;
    final oldTx = state.transactions[oldTxIndex];

    // Revert old transaction effect on balances
    var accs = state.accounts.map((acc) {
      if (oldTx.type == TransactionType.income && acc.id == oldTx.accountId) {
        return acc.copyWith(balance: acc.balance - oldTx.amount);
      } else if (oldTx.type == TransactionType.expense && acc.id == oldTx.accountId) {
        return acc.copyWith(balance: acc.balance + oldTx.amount);
      } else if (oldTx.type == TransactionType.transfer) {
        if (acc.id == oldTx.accountId) {
          return acc.copyWith(balance: acc.balance + oldTx.amount);
        } else if (acc.id == oldTx.destinationAccountId) {
          return acc.copyWith(balance: acc.balance - oldTx.amount);
        }
      }
      return acc;
    }).toList();

    // Apply new transaction effect on balances
    accs = accs.map((acc) {
      if (tx.type == TransactionType.income && acc.id == tx.accountId) {
        return acc.copyWith(balance: acc.balance + tx.amount);
      } else if (tx.type == TransactionType.expense && acc.id == tx.accountId) {
        return acc.copyWith(balance: acc.balance - tx.amount);
      } else if (tx.type == TransactionType.transfer) {
        if (acc.id == tx.accountId) {
          return acc.copyWith(balance: acc.balance - tx.amount);
        } else if (acc.id == tx.destinationAccountId) {
          return acc.copyWith(balance: acc.balance + tx.amount);
        }
      }
      return acc;
    }).toList();

    final updatedTxs = List<TransactionModel>.from(state.transactions);
    updatedTxs[oldTxIndex] = tx;

    state = state.copyWith(
      transactions: updatedTxs,
      accounts: accs,
    );
  }

  void deleteTransaction(String id) {
    final txIndex = state.transactions.indexWhere((t) => t.id == id);
    if (txIndex == -1) return;
    final tx = state.transactions[txIndex];

    // Revert balance
    final updatedAccounts = state.accounts.map((acc) {
      if (tx.type == TransactionType.income && acc.id == tx.accountId) {
        return acc.copyWith(balance: acc.balance - tx.amount);
      } else if (tx.type == TransactionType.expense && acc.id == tx.accountId) {
        return acc.copyWith(balance: acc.balance + tx.amount);
      } else if (tx.type == TransactionType.transfer) {
        if (acc.id == tx.accountId) {
          return acc.copyWith(balance: acc.balance + tx.amount);
        } else if (acc.id == tx.destinationAccountId) {
          return acc.copyWith(balance: acc.balance - tx.amount);
        }
      }
      return acc;
    }).toList();

    final updatedTxs = state.transactions.where((t) => t.id != id).toList();

    state = state.copyWith(
      transactions: updatedTxs,
      accounts: updatedAccounts,
    );
  }

  // Account CRUD
  void addAccount(Account acc) {
    state = state.copyWith(accounts: [...state.accounts, acc]);
  }

  void updateAccount(Account acc) {
    final updated = state.accounts.map((a) => a.id == acc.id ? acc : a).toList();
    state = state.copyWith(accounts: updated);
  }

  void deleteAccount(String id) {
    state = state.copyWith(accounts: state.accounts.where((a) => a.id != id).toList());
  }

  // Budget CRUD
  void addBudget(Budget b) {
    state = state.copyWith(budgets: [...state.budgets, b]);
  }

  void updateBudget(Budget b) {
    final updated = state.budgets.map((item) => item.id == b.id ? b : item).toList();
    state = state.copyWith(budgets: updated);
  }

  void deleteBudget(String id) {
    state = state.copyWith(budgets: state.budgets.where((b) => b.id != id).toList());
  }

  // Savings Goal CRUD
  void addSavingsGoal(SavingsGoal g) {
    state = state.copyWith(savingsGoals: [...state.savingsGoals, g]);
  }

  void updateSavingsGoal(SavingsGoal g) {
    final updated = state.savingsGoals.map((item) => item.id == g.id ? g : item).toList();
    state = state.copyWith(savingsGoals: updated);
  }

  void deleteSavingsGoal(String id) {
    state = state.copyWith(savingsGoals: state.savingsGoals.where((g) => g.id != id).toList());
  }

  void addGoalContribution(String goalId, double amount, String? note) {
    final index = state.savingsGoals.indexWhere((g) => g.id == goalId);
    if (index == -1) return;
    final goal = state.savingsGoals[index];
    final contribution = GoalContribution(
      id: 'c_${DateTime.now().millisecondsSinceEpoch}',
      amount: amount,
      date: DateTime.now(),
      note: note,
    );
    final updatedGoal = goal.copyWith(
      currentAmount: goal.currentAmount + amount,
      contributions: [contribution, ...goal.contributions],
    );
    final updatedList = List<SavingsGoal>.from(state.savingsGoals);
    updatedList[index] = updatedGoal;
    state = state.copyWith(savingsGoals: updatedList);
  }

  // Investment CRUD
  void addInvestment(Investment inv) {
    state = state.copyWith(investments: [...state.investments, inv]);
  }

  void updateInvestment(Investment inv) {
    final updated = state.investments.map((i) => i.id == inv.id ? inv : i).toList();
    state = state.copyWith(investments: updated);
  }

  void deleteInvestment(String id) {
    state = state.copyWith(investments: state.investments.where((i) => i.id != id).toList());
  }

  // Loan CRUD
  void addLoan(Loan loan) {
    state = state.copyWith(loans: [...state.loans, loan]);
  }

  void updateLoan(Loan loan) {
    final updated = state.loans.map((l) => l.id == loan.id ? loan : l).toList();
    state = state.copyWith(loans: updated);
  }

  void deleteLoan(String id) {
    state = state.copyWith(loans: state.loans.where((l) => l.id != id).toList());
  }

  void recordLoanPayment(String loanId, double amount, [DateTime? paymentDate]) {
    final index = state.loans.indexWhere((l) => l.id == loanId);
    if (index == -1) return;
    final loan = state.loans[index];
    final monthlyInterest = (loan.outstandingBalance * (loan.annualInterestRate / 100)) / 12;
    final principalPaid = (amount - monthlyInterest).clamp(0, amount);
    final payment = LoanPayment(
      id: 'lp_${DateTime.now().millisecondsSinceEpoch}',
      amount: amount,
      principalPaid: principalPaid.toDouble(),
      interestPaid: monthlyInterest.toDouble(),
      date: paymentDate ?? DateTime.now(),
    );
    final updatedLoan = loan.copyWith(
      outstandingBalance: (loan.outstandingBalance - principalPaid).clamp(0, double.infinity),
      payments: [payment, ...loan.payments],
    );
    final updatedLoans = List<Loan>.from(state.loans);
    updatedLoans[index] = updatedLoan;
    state = state.copyWith(loans: updatedLoans);
  }

  // Subscription CRUD
  void addSubscription(Subscription sub) {
    state = state.copyWith(subscriptions: [...state.subscriptions, sub]);
  }

  void updateSubscription(Subscription sub) {
    final updated = state.subscriptions.map((s) => s.id == sub.id ? sub : s).toList();
    state = state.copyWith(subscriptions: updated);
  }

  void cancelSubscription(String id) {
    final updated = state.subscriptions.map((s) {
      if (s.id == id) {
        return s.copyWith(status: SubscriptionStatus.cancelled);
      }
      return s;
    }).toList();
    state = state.copyWith(subscriptions: updated);
  }

  void deleteSubscription(String id) {
    state = state.copyWith(subscriptions: state.subscriptions.where((s) => s.id != id).toList());
  }

  // Category CRUD
  void addCategory(CategoryItem cat) {
    state = state.copyWith(categories: [...state.categories, cat]);
  }

  void updateCategory(CategoryItem cat) {
    final updated = state.categories.map((c) => c.id == cat.id ? cat : c).toList();
    state = state.copyWith(categories: updated);
  }

  void deleteCategory(String id) {
    state = state.copyWith(categories: state.categories.where((c) => c.id != id).toList());
  }

  // Profile
  void updateProfile(UserProfile p) {
    state = state.copyWith(profile: p);
  }

  void toggleHideBalance() {
    state = state.copyWith(profile: state.profile.copyWith(hideBalance: !state.profile.hideBalance));
  }

  void toggleTheme() {
    state = state.copyWith(profile: state.profile.copyWith(isDarkMode: !state.profile.isDarkMode));
  }
}

final financeProvider = StateNotifierProvider<FinanceNotifier, FinanceState>((ref) {
  return FinanceNotifier();
});
