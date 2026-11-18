import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../shared/widgets/fin_animated_icon.dart';

class QuickActionsBar extends StatelessWidget {
  const QuickActionsBar({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final actions = [
      _ActionItem(
        label: 'Add Expense',
        icon: LucideIcons.arrowUpRight,
        color: AppColors.warmBronze,
        onTap: () => context.push('/transactions/add?type=expense'),
      ),
      _ActionItem(
        label: 'Add Income',
        icon: LucideIcons.arrowDownLeft,
        color: AppColors.success,
        onTap: () => context.push('/transactions/add?type=income'),
      ),
      _ActionItem(
        label: 'Transfer',
        icon: LucideIcons.arrowLeftRight,
        color: isDark ? AppColors.sage : AppColors.deepForest,
        onTap: () => context.push('/transactions/add?type=transfer'),
      ),
      _ActionItem(
        label: 'Reports',
        icon: LucideIcons.barChart3,
        color: AppColors.info,
        onTap: () => context.push('/reports'),
      ),
    ];

    return Row(
      children: List.generate(actions.length, (index) {
        final action = actions[index];
        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(
              left: index == 0 ? 0 : 4,
              right: index == actions.length - 1 ? 0 : 4,
            ),
            child: Material(
              color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
              borderRadius: BorderRadius.circular(16),
              child: InkWell(
                onTap: action.onTap,
                borderRadius: BorderRadius.circular(16),
                splashColor: action.color.withValues(alpha: 0.1),
                highlightColor: action.color.withValues(alpha: 0.05),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 4),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isDark ? AppColors.borderDark : AppColors.borderLight,
                      width: 1,
                    ),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      FinAnimatedIcon(
                        icon: action.icon,
                        size: 19,
                        color: action.color,
                        backgroundColor: action.color.withValues(alpha: 0.12),
                        backgroundSize: 40,
                        borderRadius: 20, // Circular
                      ),
                      const SizedBox(height: 8),
                      Text(
                        action.label,
                        style: TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w600,
                          color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      }),
    );
  }
}

class _ActionItem {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  _ActionItem({
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
  });
}
