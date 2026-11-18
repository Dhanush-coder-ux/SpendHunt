class UserProfile {
  final String name;
  final String email;
  final String currency;
  final double monthlyIncome;
  final String primaryGoal;
  final String budgetingStyle;
  final String avatarUrl;
  final bool biometricEnabled;
  final bool notificationsEnabled;
  final bool hideBalance;
  final bool isDarkMode;

  const UserProfile({
    this.name = 'Dhanush Kumar',
    this.email = 'dhanush.kumar@example.com',
    this.currency = 'INR',
    this.monthlyIncome = 120000.0,
    this.primaryGoal = 'Buy a House & Wealth Growth',
    this.budgetingStyle = '50/30/20 Rule',
    this.avatarUrl = '',
    this.biometricEnabled = false,
    this.notificationsEnabled = true,
    this.hideBalance = false,
    this.isDarkMode = false,
  });

  UserProfile copyWith({
    String? name,
    String? email,
    String? currency,
    double? monthlyIncome,
    String? primaryGoal,
    String? budgetingStyle,
    String? avatarUrl,
    bool? biometricEnabled,
    bool? notificationsEnabled,
    bool? hideBalance,
    bool? isDarkMode,
  }) {
    return UserProfile(
      name: name ?? this.name,
      email: email ?? this.email,
      currency: currency ?? this.currency,
      monthlyIncome: monthlyIncome ?? this.monthlyIncome,
      primaryGoal: primaryGoal ?? this.primaryGoal,
      budgetingStyle: budgetingStyle ?? this.budgetingStyle,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      biometricEnabled: biometricEnabled ?? this.biometricEnabled,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      hideBalance: hideBalance ?? this.hideBalance,
      isDarkMode: isDarkMode ?? this.isDarkMode,
    );
  }
}
