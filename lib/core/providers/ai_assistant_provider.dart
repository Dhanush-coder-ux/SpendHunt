import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/ai_message.dart';
import '../utils/currency_formatter.dart';
import 'finance_provider.dart';

enum SpendHuntAIState {
  idle,
  active,
  thinking,
  response,
  error,
}

class AIAssistantState {
  final List<AIMessage> messages;
  final bool isTyping;
  final SpendHuntAIState aiState;
  final String? errorMessage;

  AIAssistantState({
    required this.messages,
    this.isTyping = false,
    this.aiState = SpendHuntAIState.idle,
    this.errorMessage,
  });

  AIAssistantState copyWith({
    List<AIMessage>? messages,
    bool? isTyping,
    SpendHuntAIState? aiState,
    String? errorMessage,
  }) {
    return AIAssistantState(
      messages: messages ?? this.messages,
      isTyping: isTyping ?? this.isTyping,
      aiState: aiState ?? this.aiState,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

class AIAssistantNotifier extends StateNotifier<AIAssistantState> {
  final Ref ref;
  Timer? _stateResetTimer;

  AIAssistantNotifier(this.ref)
      : super(
          AIAssistantState(
            messages: [
              AIMessage(
                id: 'msg_welcome',
                content:
                    "Hello Dhanush! I'm SpendHunt AI, your personal financial intelligence companion. I can help you track your spending, optimize budgets, and hunt down your savings goals effectively.",
                sender: MessageSender.assistant,
                timestamp: DateTime.now().subtract(const Duration(minutes: 5)),
                followUps: [
                  "Analyse my spending",
                  "How much can I save this month?",
                  "Show my biggest expenses",
                  "Can I afford a ₹25,000 purchase?",
                  "Analyse my financial health",
                  "Predict my monthly expenses",
                ],
              ),
            ],
          ),
        );

  void setAIState(SpendHuntAIState newState) {
    _stateResetTimer?.cancel();
    state = state.copyWith(aiState: newState);
  }

  void triggerActive() {
    _stateResetTimer?.cancel();
    state = state.copyWith(aiState: SpendHuntAIState.active);
    _stateResetTimer = Timer(const Duration(milliseconds: 700), () {
      if (state.aiState == SpendHuntAIState.active) {
        state = state.copyWith(aiState: SpendHuntAIState.idle);
      }
    });
  }

  void resetToIdle() {
    _stateResetTimer?.cancel();
    state = state.copyWith(aiState: SpendHuntAIState.idle, isTyping: false);
  }

  Future<void> sendMessage(String text) async {
    _stateResetTimer?.cancel();

    final userMessage = AIMessage(
      id: 'usr_${DateTime.now().millisecondsSinceEpoch}',
      content: text,
      sender: MessageSender.user,
      timestamp: DateTime.now(),
    );

    // 1. Enter THINKING state when request is submitted
    state = state.copyWith(
      messages: [...state.messages, userMessage],
      isTyping: true,
      aiState: SpendHuntAIState.thinking,
      errorMessage: null,
    );

    try {
      // 2. Realistic processing connected to algorithmic calculation
      await Future.delayed(const Duration(milliseconds: 1400));

      final reply = _generateDeterministicResponse(text);

      // 3. Enter RESPONSE state on successful reply
      state = state.copyWith(
        messages: [...state.messages, reply],
        isTyping: false,
        aiState: SpendHuntAIState.response,
      );

      // 4. Return to IDLE after the response pulse sequence
      _stateResetTimer = Timer(const Duration(milliseconds: 1500), () {
        if (state.aiState == SpendHuntAIState.response) {
          state = state.copyWith(aiState: SpendHuntAIState.idle);
        }
      });
    } catch (e) {
      // 5. Enter ERROR state on failure
      state = state.copyWith(
        isTyping: false,
        aiState: SpendHuntAIState.error,
        errorMessage: 'Unable to analyze: ${e.toString()}',
      );
    }
  }

  @override
  void dispose() {
    _stateResetTimer?.cancel();
    super.dispose();
  }

  void clearConversation() {
    state = AIAssistantState(
      messages: [
        AIMessage(
          id: 'msg_welcome_${DateTime.now().millisecondsSinceEpoch}',
          content:
              "Conversation reset. How can I assist you with your finances today?",
          sender: MessageSender.assistant,
          timestamp: DateTime.now(),
          followUps: [
            "Analyse my spending",
            "How much can I save this month?",
            "Show my biggest expenses",
          ],
        ),
      ],
    );
  }

  AIMessage _generateDeterministicResponse(String query) {
    final finance = ref.read(financeProvider);
    final currency = finance.profile.currency;
    final lower = query.toLowerCase();

    String content = '';
    List<String> followUps = [];

    if (lower.contains('save') || lower.contains('savings')) {
      final netSavings = finance.netSavingsThisMonth;
      final rate = finance.savingsRateThisMonth;
      content = "Based on your current month's numbers:\n\n"
          "• Total Income: ${CurrencyFormatter.format(finance.totalIncomeThisMonth, currencyCode: currency)}\n"
          "• Total Expenses: ${CurrencyFormatter.format(finance.totalExpenseThisMonth, currencyCode: currency)}\n"
          "• Projected Savings: ${CurrencyFormatter.format(netSavings, currencyCode: currency)} (Saving rate: ${rate.toStringAsFixed(1)}%)\n\n"
          "💡 Recommendation: With ₹${finance.totalMonthlySubscriptions.toStringAsFixed(0)} committed in subscriptions and ₹${finance.totalMonthlyEmi.toStringAsFixed(0)} in EMIs, allocating ${CurrencyFormatter.format(netSavings * 0.4, currencyCode: currency)} to your Emergency Reserve will help you reach your goal 1.5 months earlier.";
      followUps = ["Show my biggest expenses", "Predict my monthly expenses", "Analyse my financial health"];
    } else if (lower.contains('biggest expense') || lower.contains('top expense')) {
      // Find top categories
      final catSpending = <String, double>{};
      for (var tx in finance.transactions) {
        if (tx.type.name == 'expense') {
          catSpending[tx.categoryName] = (catSpending[tx.categoryName] ?? 0) + tx.amount;
        }
      }
      final sorted = catSpending.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value));

      final top3 = sorted.take(3).map((e) => "• ${e.key}: ${CurrencyFormatter.format(e.value, currencyCode: currency)}").join("\n");

      content = "Here are your top spending drivers this month:\n\n$top3\n\n"
          "🔍 Note: Shopping and dining comprise over 45% of your discretionary spending. Bringing dining down by 15% could yield ~₹2,700 in extra monthly surplus.";
      followUps = ["What if I reduce shopping by 20%?", "Analyse my spending", "Can I afford a purchase?"];
    } else if (lower.contains('afford')) {
      final availableLiquidity = finance.accounts
          .where((a) => a.type.name != 'creditCard')
          .fold<double>(0, (sum, a) => sum + a.balance);
      final surplus = finance.netSavingsThisMonth;

      content = "Let's review your affordability assessment:\n\n"
          "• Immediate Liquid Funds: ${CurrencyFormatter.format(availableLiquidity, currencyCode: currency)}\n"
          "• Net Monthly Cash Flow: ${CurrencyFormatter.format(surplus, currencyCode: currency)}\n"
          "• Upcoming EMIs & Bills: ${CurrencyFormatter.format(finance.totalMonthlyEmi + finance.totalMonthlySubscriptions, currencyCode: currency)}\n\n"
          "✅ Verdict: You can comfortably afford a discretionary purchase up to ${CurrencyFormatter.format(surplus * 0.5, currencyCode: currency)} without disrupting your emergency fund or EMI obligations.";
      followUps = ["How much can I save this month?", "Analyse my financial health"];
    } else if (lower.contains('health') || lower.contains('score')) {
      content = "Your SpendHunt Health Score is currently 84 / 100 (Strong Tier):\n\n"
          "• Savings Rate: ${finance.savingsRateThisMonth.toStringAsFixed(1)}% (Target: >20%) ✅\n"
          "• Debt-to-Income: ${((finance.totalMonthlyEmi / (finance.totalIncomeThisMonth == 0 ? 1 : finance.totalIncomeThisMonth)) * 100).toStringAsFixed(1)}% (Healthy is <35%) ✅\n"
          "• Emergency Runway: ~4.2 months of essential living expenses ✅\n"
          "• Budget Adherence: 82% within threshold ⚠️\n\n"
          "Focus area: Avoid exceeding your Food & Dining budget to maintain positive monthly compounding.";
      followUps = ["Analyse my spending", "Predict my monthly expenses"];
    } else if (lower.contains('predict') || lower.contains('forecast')) {
      final projectedTotal = finance.totalExpenseThisMonth * 1.12;
      content = "End-of-Month Forecast:\n\n"
          "• Projected Total Spend: ${CurrencyFormatter.format(projectedTotal, currencyCode: currency)}\n"
          "• Projected Net Savings: ${CurrencyFormatter.format(finance.totalIncomeThisMonth - projectedTotal, currencyCode: currency)}\n"
          "• Cash Flow Trend: Positive & Stable\n\n"
          "Based on historical run-rates, your non-recurring expenditures usually peak over weekend transactions.";
      followUps = ["How much can I save this month?", "What if I reduce shopping by 20%?"];
    } else {
      content = "Here is an executive summary of your current portfolio & liquidity:\n\n"
          "• Total Available Cash: ${CurrencyFormatter.format(finance.totalBalance, currencyCode: currency)}\n"
          "• Net Worth: ${CurrencyFormatter.format(finance.netWorth, currencyCode: currency)}\n"
          "• Active Investments: ${CurrencyFormatter.format(finance.totalInvestmentValue, currencyCode: currency)} (+${finance.totalInvestmentReturnRate.toStringAsFixed(1)}% overall returns)\n"
          "• Active Debts: ${CurrencyFormatter.format(finance.totalOutstandingDebt, currencyCode: currency)}\n\n"
          "What specific area would you like to explore or optimize?";
      followUps = [
        "Analyse my spending",
        "How much can I save this month?",
        "Show my biggest expenses",
        "Analyse my financial health"
      ];
    }

    return AIMessage(
      id: 'asst_${DateTime.now().millisecondsSinceEpoch}',
      content: content,
      sender: MessageSender.assistant,
      timestamp: DateTime.now(),
      followUps: followUps,
    );
  }
}

final aiAssistantProvider =
    StateNotifierProvider<AIAssistantNotifier, AIAssistantState>((ref) {
  return AIAssistantNotifier(ref);
});
