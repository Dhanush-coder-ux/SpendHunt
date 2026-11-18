import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../shared/widgets/fin_animated_icon.dart';

class AIInsightCard extends StatelessWidget {
  const AIInsightCard({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isDark ? AppColors.borderDark : AppColors.borderLight,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.goldenYellow.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    FinAnimatedIcon(
                      icon: LucideIcons.sparkles,
                      size: 13,
                      color: AppColors.warmBronze,
                      pulse: true,
                    ),
                    SizedBox(width: 5),
                    Text(
                      'SPENDHUNT AI INSIGHT',
                      style: TextStyle(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.6,
                        color: AppColors.warmBronze,
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              Text(
                'Today, 09:30 AM',
                style: TextStyle(
                  fontSize: 11,
                  color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          Text(
            'Your Dining & Food expenses rose by 14% this week',
            style: TextStyle(
              fontSize: 14.5,
              fontWeight: FontWeight.w700,
              color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
              height: 1.3,
            ),
          ),
          const SizedBox(height: 4),

          Text(
            'You\'ve spent ₹6,800 across 5 food orders. At this trajectory, your Dining budget will deplete 9 days before month-end.',
            style: TextStyle(
              fontSize: 12.5,
              color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 14),

          // Action button
          InkWell(
            onTap: () => context.go('/assistant'),
            borderRadius: BorderRadius.circular(8),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Consult SpendHunt AI',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: isDark ? AppColors.sage : AppColors.deepForest,
                  ),
                ),
                const SizedBox(width: 4),
                Icon(
                  LucideIcons.arrowRight,
                  size: 14,
                  color: isDark ? AppColors.sage : AppColors.deepForest,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
