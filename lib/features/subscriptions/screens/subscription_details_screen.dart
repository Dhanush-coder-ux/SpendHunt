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
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/confirmation_dialog.dart';
import '../../../shared/widgets/fin_animated_icon.dart';
import '../../../shared/widgets/fin_section.dart';
import '../../../shared/widgets/section_header.dart';

class SubscriptionDetailsScreen extends ConsumerWidget {
  final String subscriptionId;

  const SubscriptionDetailsScreen({super.key, required this.subscriptionId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final finance = ref.watch(financeProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final width = MediaQuery.of(context).size.width;
    final isDesktop = width >= AppConstants.tabletBreakpoint;

    final sub = finance.subscriptions.where((s) => s.id == subscriptionId).firstOrNull;

    if (sub == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Subscription Details')),
        body: const Center(child: Text('Subscription not found')),
      );
    }

    final isCancelled = sub.status == SubscriptionStatus.cancelled;

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      appBar: AppBar(
        title: Text(sub.name, maxLines: 1, overflow: TextOverflow.ellipsis),
        actions: [
          IconButton(
            onPressed: () => context.push('/subscriptions/add?editId=${sub.id}'),
            icon: const Icon(LucideIcons.pencil, size: 19),
            tooltip: 'Edit Subscription',
          ),
          IconButton(
            onPressed: () async {
              final confirmed = await ConfirmationDialog.show(
                context,
                title: 'Delete Subscription',
                message: 'Are you sure you want to delete "${sub.name}"?',
              );
              if (confirmed == true && context.mounted) {
                ref.read(financeProvider.notifier).deleteSubscription(sub.id);
                context.pop();
              }
            },
            icon: const Icon(LucideIcons.trash2, size: 19, color: AppColors.error),
            tooltip: 'Delete Subscription',
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 720),
            child: ListView(
              padding: EdgeInsets.symmetric(
                horizontal: isDesktop ? 24 : 18,
                vertical: 18,
              ),
              children: [
                // Top Hero Section
                FinSection(
                  padding: const EdgeInsets.all(22),
                  children: [
                    Center(
                      child: Column(
                        children: [
                          FinAnimatedIcon(
                            icon: LucideIcons.calendarClock,
                            size: 26,
                            color: isCancelled ? AppColors.textSecondaryLight : AppColors.deepForest,
                            backgroundColor: (isCancelled ? AppColors.textSecondaryLight : AppColors.deepForest)
                                .withValues(alpha: 0.12),
                            backgroundSize: 56,
                            borderRadius: 28,
                          ),
                          const SizedBox(height: 14),
                          Text(
                            sub.name,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                              decoration: isCancelled ? TextDecoration.lineThrough : null,
                            ),
                            textAlign: TextAlign.center,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 6),
                          Text(
                            '${CurrencyFormatter.format(sub.amount, currencyCode: finance.profile.currency)} / ${sub.billingCycle.name.toLowerCase()}',
                            style: TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.w700,
                              letterSpacing: -0.6,
                              color: isCancelled ? AppColors.textSecondaryLight : AppColors.deepForest,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                            decoration: BoxDecoration(
                              color: (isCancelled ? AppColors.error : AppColors.success).withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              isCancelled ? 'CANCELLED' : 'ACTIVE SUBSCRIPTION',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.5,
                                color: isCancelled ? AppColors.error : AppColors.success,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Details Section
                const SectionHeader(title: 'Subscription Terms & Billing'),
                const SizedBox(height: 10),

                FinSection(
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                  children: [
                    _buildDetailRow('Billing Frequency', sub.billingCycle.name.toUpperCase(), isDark),
                    const Divider(),
                    _buildDetailRow('Next Auto-Debit Date', DateFormatter.format(sub.nextBillingDate), isDark),
                    const Divider(),
                    _buildDetailRow('Debiting Account', sub.accountName, isDark),
                    const Divider(),
                    _buildDetailRow('Category', sub.categoryName, isDark),
                    const Divider(),
                    _buildDetailRow(
                      'Annualized Run Rate',
                      CurrencyFormatter.format(
                        sub.billingCycle == BillingCycle.yearly
                            ? sub.amount
                            : (sub.billingCycle == BillingCycle.quarterly ? sub.amount * 4 : sub.amount * 12),
                        currencyCode: finance.profile.currency,
                      ),
                      isDark,
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Cancellation Action
                if (!isCancelled)
                  AppButton(
                    label: 'Cancel Subscription (Simulation)',
                    icon: LucideIcons.ban,
                    variant: AppButtonVariant.danger,
                    onPressed: () async {
                      final confirmed = await ConfirmationDialog.show(
                        context,
                        title: 'Cancel Subscription',
                        message: 'Are you sure you want to cancel "${sub.name}"? This updates your local recurring budget calculations.',
                        confirmLabel: 'Cancel Plan',
                      );
                      if (confirmed == true && context.mounted) {
                        ref.read(financeProvider.notifier).cancelSubscription(sub.id);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('${sub.name} marked as cancelled'),
                            backgroundColor: AppColors.deepForest,
                          ),
                        );
                      }
                    },
                  )
                else
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppColors.error.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Center(
                      child: Text(
                        'This subscription is inactive and no longer adds to monthly recurring totals.',
                        style: TextStyle(fontSize: 12.5, color: AppColors.error, fontWeight: FontWeight.w500),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 9),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 13,
                color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 13.5,
              fontWeight: FontWeight.w600,
              color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
            ),
          ),
        ],
      ),
    );
  }
}
