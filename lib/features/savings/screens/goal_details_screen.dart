import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../app/theme/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/providers/finance_provider.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/app_text_field.dart';
import '../../../shared/widgets/confirmation_dialog.dart';
import '../../../shared/widgets/fin_animated_icon.dart';
import '../../../shared/widgets/fin_list_tile.dart';
import '../../../shared/widgets/fin_section.dart';
import '../../../shared/widgets/section_header.dart';

class GoalDetailsScreen extends ConsumerWidget {
  final String goalId;

  const GoalDetailsScreen({super.key, required this.goalId});

  void _showAddContributionSheet(BuildContext context, WidgetRef ref, String currency) {
    final amountController = TextEditingController();
    final noteController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(
            left: 22,
            right: 22,
            top: 22,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 22,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Add Goal Deposit', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
              const SizedBox(height: 14),
              AppTextField(
                controller: amountController,
                label: 'Deposit Amount ($currency)',
                hintText: '5000',
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                prefixIcon: const Icon(LucideIcons.coins, size: 18),
              ),
              const SizedBox(height: 12),
              AppTextField(
                controller: noteController,
                label: 'Deposit Notes (Optional)',
                hintText: 'e.g. Monthly salary savings allocation',
                prefixIcon: const Icon(LucideIcons.notepadText, size: 18),
              ),
              const SizedBox(height: 20),
              AppButton(
                label: 'Confirm Contribution',
                onPressed: () {
                  final amount = double.tryParse(amountController.text.trim()) ?? 0.0;
                  if (amount <= 0) return;

                  ref.read(financeProvider.notifier).addGoalContribution(
                        goalId,
                        amount,
                        noteController.text.trim().isNotEmpty ? noteController.text.trim() : null,
                      );
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Added ${CurrencyFormatter.format(amount, currencyCode: currency)} to goal!'),
                      backgroundColor: AppColors.deepForest,
                    ),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final finance = ref.watch(financeProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final width = MediaQuery.of(context).size.width;
    final isDesktop = width >= AppConstants.tabletBreakpoint;

    final goal = finance.savingsGoals.where((g) => g.id == goalId).firstOrNull;

    if (goal == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Goal Details')),
        body: const Center(child: Text('Goal not found')),
      );
    }

    final progress = goal.progressPercentage;
    final isDone = goal.isCompleted;

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      appBar: AppBar(
        title: Text(goal.name, maxLines: 1, overflow: TextOverflow.ellipsis),
        actions: [
          IconButton(
            onPressed: () => context.push('/savings/create?editId=${goal.id}'),
            icon: const Icon(LucideIcons.pencil, size: 19),
            tooltip: 'Edit Goal',
          ),
          IconButton(
            onPressed: () async {
              final confirmed = await ConfirmationDialog.show(
                context,
                title: 'Delete Savings Goal',
                message: 'Are you sure you want to delete "${goal.name}"?',
              );
              if (confirmed == true && context.mounted) {
                ref.read(financeProvider.notifier).deleteSavingsGoal(goal.id);
                context.pop();
              }
            },
            icon: const Icon(LucideIcons.trash2, size: 19, color: AppColors.error),
            tooltip: 'Delete Goal',
          ),
          const SizedBox(width: 8),
        ],
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? AppColors.surfaceDark : Colors.white,
          border: Border(top: BorderSide(color: (isDark ? AppColors.borderDark : AppColors.borderLight).withValues(alpha: 0.8))),
        ),
        child: SafeArea(
          child: AppButton(
            label: 'Add Savings Contribution',
            icon: LucideIcons.circlePlus,
            onPressed: () => _showAddContributionSheet(context, ref, finance.profile.currency),
          ),
        ),
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
                // Goal Summary Section
                FinSection(
                  padding: const EdgeInsets.all(22),
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            'Target Date: ${DateFormatter.formatShort(goal.targetDate)}',
                            style: TextStyle(
                              fontSize: 12.5,
                              color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: (isDone ? AppColors.success : AppColors.deepForest).withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            '${(progress * 100).toStringAsFixed(0)}% Saved',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: isDone ? AppColors.success : AppColors.deepForest,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      goal.name,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      CurrencyFormatter.format(goal.currentAmount, currencyCode: finance.profile.currency),
                      style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.8,
                        color: isDark ? AppColors.textPrimaryDark : AppColors.deepForest,
                      ),
                    ),
                    const SizedBox(height: 14),

                    ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: LinearProgressIndicator(
                        value: progress,
                        backgroundColor: isDark
                            ? AppColors.surfaceSecondaryDark
                            : AppColors.surfaceSecondaryLight,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          isDone ? AppColors.success : (isDark ? AppColors.sage : AppColors.deepForest),
                        ),
                        minHeight: 8,
                      ),
                    ),
                    const SizedBox(height: 12),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            'Target: ${CurrencyFormatter.format(goal.targetAmount, currencyCode: finance.profile.currency)}',
                            style: const TextStyle(fontSize: 12.5, color: AppColors.textSecondaryLight),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          isDone
                              ? 'Target Reached!'
                              : 'Remaining: ${CurrencyFormatter.format(goal.remainingAmount, currencyCode: finance.profile.currency)}',
                          style: TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w600,
                            color: isDone ? AppColors.success : AppColors.warmBronze,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 22),

                // Contribution History
                SectionHeader(
                  title: 'Contribution History',
                  subtitle: '${goal.contributions.length} deposits recorded',
                ),
                const SizedBox(height: 10),

                if (goal.contributions.isEmpty)
                  FinSection(
                    padding: const EdgeInsets.all(24),
                    children: [
                      Center(
                        child: Text(
                          'No contributions recorded yet. Tap "Add Savings Contribution" below.',
                          style: TextStyle(
                            fontSize: 13,
                            color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  )
                else
                  FinSection(
                    children: List.generate(goal.contributions.length, (index) {
                      final c = goal.contributions[index];
                      final isLast = index == goal.contributions.length - 1;

                      return FinListTile(
                        leading: const FinAnimatedIcon(
                          icon: LucideIcons.circleCheck,
                          size: 18,
                          color: AppColors.success,
                          backgroundColor: Color(0x1F548B68),
                          backgroundSize: 38,
                          borderRadius: 10,
                        ),
                        title: c.notes ?? 'Deposit Contribution',
                        subtitle: DateFormatter.formatRelative(c.date),
                        trailingTitle: '+${CurrencyFormatter.format(c.amount, currencyCode: finance.profile.currency)}',
                        trailingTitleColor: AppColors.success,
                        showDivider: !isLast,
                      );
                    }),
                  ),
                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
