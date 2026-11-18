import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../app/theme/app_colors.dart';
import 'fin_animated_icon.dart';
import 'spendhunt_ai_orb.dart';

class AppBottomNavigation extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const AppBottomNavigation({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? AppColors.surfaceDark : AppColors.surfaceLight;
    final border = isDark ? AppColors.borderDark : AppColors.borderLight;

    final items = [
      _NavItem(icon: LucideIcons.layoutDashboard, label: 'Home'),
      _NavItem(icon: LucideIcons.arrowUpDown, label: 'Activity'),
      _NavItem(icon: LucideIcons.pieChart, label: 'Budgets'),
      _NavItem(icon: LucideIcons.sparkles, label: 'SpendHunt AI', isAiAssistant: true),
      _NavItem(icon: LucideIcons.user, label: 'Profile'),
    ];

    return Container(
      decoration: BoxDecoration(
        color: bg,
        border: Border(top: BorderSide(color: border.withValues(alpha: 0.8), width: 1)),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 64,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(items.length, (index) {
              final item = items[index];
              final isSelected = currentIndex == index;

              final iconColor = isSelected
                  ? (isDark ? AppColors.sage : AppColors.deepForest)
                  : (isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight);

              return Expanded(
                child: InkWell(
                  onTap: () => onTap(index),
                  splashColor: Colors.transparent,
                  highlightColor: Colors.transparent,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (item.isAiAssistant)
                        // Programmatic native animated SpendHunt AI energy orb
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          curve: Curves.easeOutCubic,
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? (isDark
                                    ? AppColors.goldenYellow.withValues(alpha: 0.16)
                                    : AppColors.deepForest.withValues(alpha: 0.08))
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: SpendHuntAIOrb(
                            size: 32,
                            showGlow: isSelected,
                          ),
                        )
                      else
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          curve: Curves.easeOutCubic,
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? (isDark
                                    ? AppColors.surfaceSecondaryDark
                                    : AppColors.deepForest.withValues(alpha: 0.08))
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: FinAnimatedIcon(
                            icon: item.icon,
                            size: 20,
                            color: iconColor,
                            animateEntry: isSelected,
                          ),
                        ),
                      const SizedBox(height: 3),
                      Text(
                        item.label,
                        style: TextStyle(
                          fontSize: item.isAiAssistant ? 10.5 : 11,
                          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                          color: isSelected
                              ? (isDark ? AppColors.textPrimaryDark : AppColors.deepForest)
                              : (isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}

class _NavItem {
  final IconData icon;
  final String label;
  final bool isAiAssistant;

  _NavItem({
    required this.icon,
    required this.label,
    this.isAiAssistant = false,
  });
}
