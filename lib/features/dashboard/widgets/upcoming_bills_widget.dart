import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/models/subscription.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../shared/widgets/fin_animated_icon.dart';
import '../../../../shared/widgets/fin_list_tile.dart';
import '../../../../shared/widgets/fin_section.dart';
import '../../../../shared/widgets/section_header.dart';

class UpcomingBillsWidget extends StatelessWidget {
  final List<Subscription> subscriptions;
  final String currency;

  const UpcomingBillsWidget({
    super.key,
    required this.subscriptions,
    this.currency = 'INR',
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final activeSubs = subscriptions
        .where((s) => s.status == SubscriptionStatus.active)
        .toList();
    activeSubs.sort((a, b) => a.nextBillingDate.compareTo(b.nextBillingDate));
    final displaySubs = activeSubs.take(3).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(
          title: 'Upcoming Payments',
          actionLabel: 'View All',
          onAction: () => context.push('/subscriptions'),
        ),
        const SizedBox(height: 10),
        FinSection(
          children: List.generate(displaySubs.length, (index) {
            final sub = displaySubs[index];
            final isLast = index == displaySubs.length - 1;
            final daysLeft = sub.nextBillingDate.difference(DateTime.now()).inDays;

            String dueLabel;
            if (daysLeft < 0) {
              dueLabel = 'Overdue by ${daysLeft.abs()}d';
            } else if (daysLeft == 0) {
              dueLabel = 'Due Today';
            } else if (daysLeft == 1) {
              dueLabel = 'Due Tomorrow';
            } else {
              dueLabel = 'Due in $daysLeft days';
            }

            return FinListTile(
              onTap: () => context.push('/subscriptions/details/${sub.id}'),
              leading: FinAnimatedIcon(
                icon: LucideIcons.calendarClock,
                size: 18,
                color: isDark ? AppColors.sage : AppColors.deepForest,
                backgroundColor: isDark ? AppColors.surfaceSecondaryDark : AppColors.surfaceSecondaryLight,
                backgroundSize: 40,
                borderRadius: 12,
              ),
              title: sub.name,
              subtitle: 'Due: ${DateFormatter.formatShort(sub.nextBillingDate)}',
              trailingTitle: CurrencyFormatter.format(sub.amount, currencyCode: currency),
              trailingSubtitle: dueLabel,
              trailingTitleColor: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
              showDivider: !isLast,
            );
          }),
        ),
      ],
    );
  }
}
