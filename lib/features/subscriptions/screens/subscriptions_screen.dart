import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../app/theme/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/models/subscription.dart';
import '../../../core/providers/finance_provider.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../../shared/widgets/fin_animated_icon.dart';
import '../../../shared/widgets/fin_list_tile.dart';
import '../../../shared/widgets/fin_section.dart';

class SubscriptionsScreen extends ConsumerStatefulWidget {
  const SubscriptionsScreen({super.key});

  @override
  ConsumerState<SubscriptionsScreen> createState() => _SubscriptionsScreenState();
}

class _SubscriptionsScreenState extends ConsumerState<SubscriptionsScreen> {
  int _selectedFilter = 0; // 0: All Active, 1: Due Soon, 2: Cancelled

  @override
  Widget build(BuildContext context) {
    final finance = ref.watch(financeProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final width = MediaQuery.of(context).size.width;
    final isDesktop = width >= AppConstants.tabletBreakpoint;

    final now = DateTime.now();

    final filtered = finance.subscriptions.where((s) {
      if (_selectedFilter == 0) return s.status == SubscriptionStatus.active;
      if (_selectedFilter == 1) {
        final diff = s.nextBillingDate.difference(now).inDays;
        return s.status == SubscriptionStatus.active && diff >= 0 && diff <= 7;
      }
      if (_selectedFilter == 2) return s.status == SubscriptionStatus.cancelled;
      return true;
    }).toList();

    filtered.sort((a, b) => a.nextBillingDate.compareTo(b.nextBillingDate));

    double monthlyTotal = 0.0;
    for (var s in finance.subscriptions) {
      if (s.status == SubscriptionStatus.active) {
        if (s.billingCycle == BillingCycle.yearly) {
          monthlyTotal += s.amount / 12;
        } else {
          monthlyTotal += s.amount;
        }
      }
    }

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      appBar: AppBar(
        title: const Text('Recurring Subscriptions', style: TextStyle(fontWeight: FontWeight.w700)),
        actions: [
          IconButton(
            onPressed: () => context.push('/subscriptions/add'),
            icon: const Icon(LucideIcons.plus, size: 20),
            tooltip: 'Add Subscription',
          ),
          const SizedBox(width: 8),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/subscriptions/add'),
        backgroundColor: AppColors.deepForest,
        foregroundColor: Colors.white,
        icon: const Icon(LucideIcons.plus, size: 18),
        label: const Text('Add Recurring', style: TextStyle(fontWeight: FontWeight.w600)),
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
              // Hero Monthly Commitment Card
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
                            'MONTHLY RECURRING COMMITMENT',
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
                            '${finance.subscriptions.where((s) => s.status == SubscriptionStatus.active).length} Active',
                            style: const TextStyle(fontSize: 11, color: Colors.white, fontWeight: FontWeight.w600),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      CurrencyFormatter.format(monthlyTotal, currencyCode: finance.profile.currency),
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.8,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Includes entertainment, utilities, fiber broadband and memberships',
                      style: TextStyle(fontSize: 12.5, color: Colors.white.withValues(alpha: 0.75)),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Filter Tabs
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.surfaceSecondaryDark : AppColors.surfaceSecondaryLight,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    _buildTab('Active (${finance.subscriptions.where((s) => s.status == SubscriptionStatus.active).length})', 0, isDark),
                    _buildTab('Due This Week', 1, isDark),
                    _buildTab('Cancelled', 2, isDark),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Subscriptions Flat List
              if (filtered.isEmpty)
                EmptyState(
                  title: 'No subscriptions found',
                  description: 'Track your streaming services, utilities, and memberships.',
                  icon: LucideIcons.calendarClock,
                  actionLabel: 'Add Subscription',
                  onAction: () => context.push('/subscriptions/add'),
                )
              else
                FinSection(
                  children: List.generate(filtered.length, (index) {
                    final sub = filtered[index];
                    final isLast = index == filtered.length - 1;
                    final daysLeft = sub.nextBillingDate.difference(DateTime.now()).inDays;
                    final isOverdue = daysLeft < 0;
                    final isCancelled = sub.status == SubscriptionStatus.cancelled;

                    String scheduleText;
                    if (isCancelled) {
                      scheduleText = 'Cancelled';
                    } else if (isOverdue) {
                      scheduleText = 'Overdue by ${daysLeft.abs()}d';
                    } else if (daysLeft == 0) {
                      scheduleText = 'Due Today';
                    } else {
                      scheduleText = 'Renews in ${daysLeft}d';
                    }

                    return FinListTile(
                      onTap: () => context.push('/subscriptions/details/${sub.id}'),
                      leading: FinAnimatedIcon(
                        icon: isCancelled ? LucideIcons.calendarX : LucideIcons.calendarClock,
                        size: 19,
                        color: isCancelled
                            ? AppColors.textSecondaryLight
                            : (isOverdue ? AppColors.error : AppColors.deepForest),
                        backgroundColor: (isCancelled
                                ? AppColors.textSecondaryLight
                                : (isOverdue ? AppColors.error : AppColors.deepForest))
                            .withValues(alpha: 0.12),
                        backgroundSize: 40,
                        borderRadius: 12,
                      ),
                      title: sub.name,
                      subtitle: '${sub.categoryName} • ${DateFormatter.formatShort(sub.nextBillingDate)}',
                      trailingTitle: CurrencyFormatter.format(sub.amount, currencyCode: finance.profile.currency),
                      trailingSubtitle: scheduleText,
                      trailingTitleColor: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
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

  Widget _buildTab(String label, int index, bool isDark) {
    final isSelected = _selectedFilter == index;
    return Expanded(
      child: InkWell(
        onTap: () => setState(() => _selectedFilter = index),
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isSelected
                ? (isDark ? AppColors.deepForest : Colors.white)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                color: isSelected
                    ? (isDark ? Colors.white : AppColors.deepForest)
                    : (isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight),
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
      ),
    );
  }
}
