enum NotificationCategory {
  budgetAlert,
  upcomingPayment,
  savingsMilestone,
  aiInsight,
  transaction,
}

extension NotificationCategoryExtension on NotificationCategory {
  String get displayName {
    switch (this) {
      case NotificationCategory.budgetAlert:
        return 'Budget Alert';
      case NotificationCategory.upcomingPayment:
        return 'Upcoming Payment';
      case NotificationCategory.savingsMilestone:
        return 'Savings Milestone';
      case NotificationCategory.aiInsight:
        return 'AI Insight';
      case NotificationCategory.transaction:
        return 'Transaction';
    }
  }
}

class NotificationItem {
  final String id;
  final String title;
  final String message;
  final NotificationCategory category;
  final DateTime timestamp;
  final bool isRead;
  final String? route;

  NotificationItem({
    required this.id,
    required this.title,
    required this.message,
    required this.category,
    required this.timestamp,
    this.isRead = false,
    this.route,
  });

  String? get actionRoute => route;

  NotificationItem copyWith({
    String? id,
    String? title,
    String? message,
    NotificationCategory? category,
    DateTime? timestamp,
    bool? isRead,
    String? route,
  }) {
    return NotificationItem(
      id: id ?? this.id,
      title: title ?? this.title,
      message: message ?? this.message,
      category: category ?? this.category,
      timestamp: timestamp ?? this.timestamp,
      isRead: isRead ?? this.isRead,
      route: route ?? this.route,
    );
  }
}
