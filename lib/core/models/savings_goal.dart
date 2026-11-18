class GoalContribution {
  final String id;
  final double amount;
  final DateTime date;
  final String? note;

  GoalContribution({
    required this.id,
    required this.amount,
    required this.date,
    this.note,
  });

  String? get notes => note;
}

class SavingsGoal {
  final String id;
  final String name;
  final double targetAmount;
  final double currentAmount;
  final DateTime targetDate;
  final String category;
  final String iconName;
  final List<GoalContribution> contributions;
  final DateTime createdAt;

  SavingsGoal({
    required this.id,
    required this.name,
    required this.targetAmount,
    required this.currentAmount,
    required this.targetDate,
    this.category = 'General',
    this.iconName = 'piggyBank',
    List<GoalContribution>? contributions,
    DateTime? createdAt,
  })  : contributions = contributions ?? [],
        createdAt = createdAt ?? DateTime.now();

  double get remainingAmount => (targetAmount - currentAmount).clamp(0, double.infinity);
  double get progressPercentage => targetAmount > 0 ? (currentAmount / targetAmount).clamp(0.0, 1.0) : 0.0;
  bool get isCompleted => currentAmount >= targetAmount;

  SavingsGoal copyWith({
    String? id,
    String? name,
    double? targetAmount,
    double? currentAmount,
    DateTime? targetDate,
    String? category,
    String? iconName,
    List<GoalContribution>? contributions,
    DateTime? createdAt,
  }) {
    return SavingsGoal(
      id: id ?? this.id,
      name: name ?? this.name,
      targetAmount: targetAmount ?? this.targetAmount,
      currentAmount: currentAmount ?? this.currentAmount,
      targetDate: targetDate ?? this.targetDate,
      category: category ?? this.category,
      iconName: iconName ?? this.iconName,
      contributions: contributions ?? this.contributions,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
