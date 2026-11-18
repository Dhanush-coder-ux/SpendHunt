import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:finpilot_ai/core/models/transaction.dart';
import 'package:finpilot_ai/core/models/loan.dart';
import 'package:finpilot_ai/core/providers/finance_provider.dart';

void main() {
  group('Finance Provider & State Calculations', () {
    test('Initial financial state is populated with realistic mock data', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final state = container.read(financeProvider);
      expect(state.accounts.isNotEmpty, isTrue);
      expect(state.transactions.isNotEmpty, isTrue);
      expect(state.budgets.isNotEmpty, isTrue);
      expect(state.savingsGoals.isNotEmpty, isTrue);
      expect(state.investments.isNotEmpty, isTrue);
      expect(state.loans.isNotEmpty, isTrue);
      expect(state.subscriptions.isNotEmpty, isTrue);

      expect(state.totalBalance, greaterThan(0));
      expect(state.totalInvestmentValue, greaterThan(0));
      expect(state.totalOutstandingDebt, greaterThan(0));
      expect(state.netWorth, isNotNull);
    });

    test('Adding an expense updates account balance and expense totals reactively', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier = container.read(financeProvider.notifier);
      final initialState = container.read(financeProvider);

      final targetAccount = initialState.accounts.first;
      final initialBalance = targetAccount.balance;
      final initialExpenses = initialState.totalExpenseThisMonth;

      final testTx = TransactionModel(
        id: 'test_expense_1',
        title: 'Artisan Coffee',
        merchant: 'Blue Tokai',
        amount: 350.0,
        type: TransactionType.expense,
        categoryId: 'cat_food',
        categoryName: 'Food & Dining',
        accountId: targetAccount.id,
        accountName: targetAccount.name,
        date: DateTime.now(),
      );

      notifier.addTransaction(testTx);

      final updatedState = container.read(financeProvider);
      final updatedAccount = updatedState.accounts.firstWhere((a) => a.id == targetAccount.id);

      expect(updatedAccount.balance, equals(initialBalance - 350.0));
      expect(updatedState.totalExpenseThisMonth, equals(initialExpenses + 350.0));
      expect(updatedState.transactions.first.id, equals('test_expense_1'));

      // Delete transaction should revert balance
      notifier.deleteTransaction('test_expense_1');
      final revertedState = container.read(financeProvider);
      final revertedAccount = revertedState.accounts.firstWhere((a) => a.id == targetAccount.id);

      expect(revertedAccount.balance, equals(initialBalance));
      expect(revertedState.totalExpenseThisMonth, equals(initialExpenses));
    });

    test('Adding an income updates account balance and monthly income', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier = container.read(financeProvider.notifier);
      final initialState = container.read(financeProvider);

      final targetAccount = initialState.accounts.first;
      final initialBalance = targetAccount.balance;
      final initialIncome = initialState.totalIncomeThisMonth;

      final testTx = TransactionModel(
        id: 'test_income_1',
        title: 'Consulting Honorarium',
        merchant: 'Client A',
        amount: 20000.0,
        type: TransactionType.income,
        categoryId: 'cat_freelance',
        categoryName: 'Freelance & Consulting',
        accountId: targetAccount.id,
        accountName: targetAccount.name,
        date: DateTime.now(),
      );

      notifier.addTransaction(testTx);

      final updatedState = container.read(financeProvider);
      final updatedAccount = updatedState.accounts.firstWhere((a) => a.id == targetAccount.id);

      expect(updatedAccount.balance, equals(initialBalance + 20000.0));
      expect(updatedState.totalIncomeThisMonth, equals(initialIncome + 20000.0));
    });

    test('Transfer moves money between source and destination accounts', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier = container.read(financeProvider.notifier);
      final initialState = container.read(financeProvider);

      final src = initialState.accounts[0];
      final dest = initialState.accounts[1];

      final srcBalance = src.balance;
      final destBalance = dest.balance;

      final transferTx = TransactionModel(
        id: 'test_tx_transfer',
        title: 'Savings Allocation',
        amount: 10000.0,
        type: TransactionType.transfer,
        categoryId: 'cat_transfer',
        categoryName: 'Account Transfer',
        accountId: src.id,
        accountName: src.name,
        destinationAccountId: dest.id,
        destinationAccountName: dest.name,
        date: DateTime.now(),
      );

      notifier.addTransaction(transferTx);

      final updatedState = container.read(financeProvider);
      final updatedSrc = updatedState.accounts.firstWhere((a) => a.id == src.id);
      final updatedDest = updatedState.accounts.firstWhere((a) => a.id == dest.id);

      expect(updatedSrc.balance, equals(srcBalance - 10000.0));
      expect(updatedDest.balance, equals(destBalance + 10000.0));
    });

    test('Savings goal contribution increases current saved amount', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier = container.read(financeProvider.notifier);
      final initialGoal = container.read(financeProvider).savingsGoals.first;
      final initialSaved = initialGoal.currentAmount;

      notifier.addGoalContribution(initialGoal.id, 5000.0, 'Monthly bonus stash');

      final updatedGoal = container
          .read(financeProvider)
          .savingsGoals
          .firstWhere((g) => g.id == initialGoal.id);

      expect(updatedGoal.currentAmount, equals(initialSaved + 5000.0));
      expect(updatedGoal.contributions.first.amount, equals(5000.0));
    });

    test('Recording loan EMI reduces outstanding balance', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier = container.read(financeProvider.notifier);
      final initialLoan = container.read(financeProvider).loans.first;
      final initialBalance = initialLoan.outstandingBalance;

      notifier.recordLoanPayment(initialLoan.id, initialLoan.monthlyEmi);

      final updatedLoan = container
          .read(financeProvider)
          .loans
          .firstWhere((l) => l.id == initialLoan.id);

      expect(updatedLoan.outstandingBalance, lessThan(initialBalance));
      expect(updatedLoan.payments.isNotEmpty, isTrue);
    });

    test('EMI mathematical formula accurately computes monthly installment', () {
      // 5,00,000 at 8.5% for 60 months
      final emi = Loan.calculateEmi(principal: 500000, annualRate: 8.5, tenureMonths: 60);
      expect(emi, greaterThan(10000));
      expect(emi, lessThan(11000));
    });
  });
}
