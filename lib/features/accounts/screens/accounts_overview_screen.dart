import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../app/theme/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/models/account.dart';
import '../../../core/providers/finance_provider.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../shared/widgets/fin_animated_icon.dart';
import '../../../shared/widgets/fin_list_tile.dart';
import '../../../shared/widgets/fin_section.dart';

class AccountsOverviewScreen extends ConsumerWidget {
  const AccountsOverviewScreen({super.key});

  IconData _getAccountIcon(AccountType type) {
    switch (type) {
      case AccountType.savings:
        return LucideIcons.landmark;
      case AccountType.current:
        return LucideIcons.briefcase;
      case AccountType.creditCard:
        return LucideIcons.creditCard;
      case AccountType.cash:
        return LucideIcons.banknote;
      case AccountType.digitalWallet:
        return LucideIcons.smartphone;
    }
  }

  Color _getAccountColor(AccountType type) {
    switch (type) {
      case AccountType.savings:
        return AppColors.deepForest;
      case AccountType.current:
        return AppColors.info;
      case AccountType.creditCard:
        return AppColors.warmBronze;
      case AccountType.cash:
        return AppColors.success;
      case AccountType.digitalWallet:
        return AppColors.catEntertainment;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final finance = ref.watch(financeProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final width = MediaQuery.of(context).size.width;
    final isDesktop = width >= AppConstants.tabletBreakpoint;

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      appBar: AppBar(
        title: const Text('Accounts & Cards', style: TextStyle(fontWeight: FontWeight.w700)),
        actions: [
          IconButton(
            onPressed: () => context.push('/accounts/add'),
            icon: const Icon(LucideIcons.plus, size: 20),
            tooltip: 'Add Account',
          ),
          const SizedBox(width: 8),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/accounts/add'),
        backgroundColor: AppColors.deepForest,
        foregroundColor: Colors.white,
        icon: const Icon(LucideIcons.plus, size: 18),
        label: const Text('New Account', style: TextStyle(fontWeight: FontWeight.w600)),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(
            horizontal: isDesktop ? 32 : 18,
            vertical: 18,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Total Balance Hero Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  color: AppColors.deepForest,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            'TOTAL CUMULATIVE BALANCE',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.8,
                              color: Colors.white.withValues(alpha: 0.7),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            '${finance.accounts.length} Active Accounts',
                            style: const TextStyle(fontSize: 11, color: Colors.white, fontWeight: FontWeight.w600),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      CurrencyFormatter.format(finance.totalBalance, currencyCode: finance.profile.currency),
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.8,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(height: 1, color: Colors.white.withValues(alpha: 0.12)),
                    const SizedBox(height: 14),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Cash & Liquid Savings',
                                style: TextStyle(fontSize: 11.5, color: Colors.white.withValues(alpha: 0.7)),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 2),
                              Text(
                                CurrencyFormatter.format(
                                  finance.accounts
                                      .where((a) => a.type == AccountType.savings || a.type == AccountType.cash)
                                      .fold(0.0, (sum, a) => sum + a.balance),
                                  currencyCode: finance.profile.currency,
                                ),
                                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.goldenYellow),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              'Credit Card Outstandings',
                              style: TextStyle(fontSize: 11.5, color: Colors.white.withValues(alpha: 0.7)),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              CurrencyFormatter.format(
                                finance.accounts
                                    .where((a) => a.type == AccountType.creditCard)
                                    .fold(0.0, (sum, a) => sum + a.balance.abs()),
                                currencyCode: finance.profile.currency,
                              ),
                              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Colors.white),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              Text(
                'YOUR ACCOUNTS',
                style: TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.8,
                  color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                ),
              ),
              const SizedBox(height: 12),

              // Clean Flat Accounts Section
              FinSection(
                children: List.generate(finance.accounts.length, (index) {
                  final acc = finance.accounts[index];
                  final isLast = index == finance.accounts.length - 1;
                  final color = _getAccountColor(acc.type);
                  final icon = _getAccountIcon(acc.type);
                  final isNegative = acc.balance < 0;

                  return FinListTile(
                    onTap: () => context.push('/accounts/details/${acc.id}'),
                    leading: FinAnimatedIcon(
                      icon: icon,
                      size: 19,
                      color: color,
                      backgroundColor: color.withValues(alpha: 0.12),
                      backgroundSize: 40,
                      borderRadius: 12,
                    ),
                    title: acc.name,
                    subtitle: '${acc.type.name.toUpperCase()} •••• ${acc.lastFourDigits}',
                    trailingTitle: CurrencyFormatter.format(acc.balance, currencyCode: finance.profile.currency),
                    trailingSubtitle: isNegative ? 'Outstanding' : 'Available',
                    trailingTitleColor: isNegative
                        ? AppColors.error
                        : (isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight),
                    showDivider: !isLast,
                  );
                }),
              ),
              const SizedBox(height: 60),
            ],
          ),
        ),
      ),
    );
  }
}
