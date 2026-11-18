import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../app/theme/app_colors.dart';
import '../../core/constants/app_constants.dart';
import 'spendhunt_ai_orb.dart';

class AppSidebar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onSelectIndex;
  final VoidCallback? onToggleCollapse;
  final bool isCollapsed;
  final void Function(String route) onNavigate;

  const AppSidebar({
    super.key,
    required this.currentIndex,
    required this.onSelectIndex,
    this.onToggleCollapse,
    this.isCollapsed = false,
    required this.onNavigate,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? AppColors.surfaceDark : AppColors.surfaceLight;
    final border = isDark ? AppColors.borderDark : AppColors.borderLight;

    return Container(
      width: isCollapsed ? 76 : 240,
      decoration: BoxDecoration(
        color: bg,
        border: Border(right: BorderSide(color: border, width: 1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Logo & Branding
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: isCollapsed ? 16 : 20,
              vertical: 20,
            ),
            child: Row(
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.08),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: Image.asset(
                    AppConstants.appLogo,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Image.asset(
                        AppConstants.appLogoNormalized,
                        fit: BoxFit.cover,
                        errorBuilder: (ctx, err, st) => const Icon(
                          Icons.account_balance_wallet_rounded,
                          color: AppColors.deepForest,
                          size: 20,
                        ),
                      );
                    },
                  ),
                ),
                if (!isCollapsed) ...[
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          AppConstants.appName,
                          style: TextStyle(
                            fontSize: 16.5,
                            fontWeight: FontWeight.w700,
                            letterSpacing: -0.3,
                            color: AppColors.deepForest,
                          ),
                        ),
                        Text(
                          'Personal Finance',
                          style: TextStyle(
                            fontSize: 10.5,
                            color: AppColors.textSecondaryLight,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
          const Divider(),

          // Main Destinations
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
              children: [
                _buildNavItem(
                  context,
                  index: 0,
                  icon: LucideIcons.layoutDashboard,
                  label: 'Home Dashboard',
                  isSelected: currentIndex == 0,
                ),
                _buildNavItem(
                  context,
                  index: 1,
                  icon: LucideIcons.arrowUpDown,
                  label: 'Transactions',
                  isSelected: currentIndex == 1,
                ),
                _buildNavItem(
                  context,
                  index: 2,
                  icon: LucideIcons.pieChart,
                  label: 'Budgets',
                  isSelected: currentIndex == 2,
                ),
                _buildNavItem(
                  context,
                  index: 3,
                  icon: LucideIcons.sparkles,
                  label: 'AI Assistant',
                  isSelected: currentIndex == 3,
                  isSpecial: true,
                ),
                _buildNavItem(
                  context,
                  index: 4,
                  icon: LucideIcons.user,
                  label: 'Profile',
                  isSelected: currentIndex == 4,
                ),

                const SizedBox(height: 16),
                if (!isCollapsed)
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    child: Text(
                      'MANAGEMENT',
                      style: TextStyle(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.8,
                        color: AppColors.textSecondaryLight,
                      ),
                    ),
                  ),
                _buildShortcutItem(
                  context,
                  icon: LucideIcons.wallet,
                  label: 'Accounts',
                  onTap: () => onNavigate('/accounts'),
                ),
                _buildShortcutItem(
                  context,
                  icon: LucideIcons.target,
                  label: 'Savings Goals',
                  onTap: () => onNavigate('/savings'),
                ),
                _buildShortcutItem(
                  context,
                  icon: LucideIcons.trendingUp,
                  label: 'Investments',
                  onTap: () => onNavigate('/investments'),
                ),
                _buildShortcutItem(
                  context,
                  icon: LucideIcons.landmark,
                  label: 'Loans & EMI',
                  onTap: () => onNavigate('/loans'),
                ),
                _buildShortcutItem(
                  context,
                  icon: LucideIcons.calendarClock,
                  label: 'Subscriptions',
                  onTap: () => onNavigate('/subscriptions'),
                ),
                _buildShortcutItem(
                  context,
                  icon: LucideIcons.scanLine,
                  label: 'Scan Receipt',
                  onTap: () => onNavigate('/receipt-scanner'),
                ),
                _buildShortcutItem(
                  context,
                  icon: LucideIcons.barChart3,
                  label: 'Reports & Analytics',
                  onTap: () => onNavigate('/reports'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem(
    BuildContext context, {
    required int index,
    required IconData icon,
    required String label,
    required bool isSelected,
    bool isSpecial = false,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Material(
        color: isSelected
            ? (isSpecial
                ? AppColors.goldenYellow.withValues(alpha: 0.15)
                : (isDark
                    ? AppColors.surfaceSecondaryDark
                    : AppColors.deepForest.withValues(alpha: 0.08)))
            : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: () => onSelectIndex(index),
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
            child: Row(
              children: [
                if (isSpecial)
                  SpendHuntAIOrb(
                    size: 22,
                    showGlow: isSelected,
                  )
                else
                  Icon(
                    icon,
                    size: 20,
                    color: isSelected
                        ? (isDark ? AppColors.textPrimaryDark : AppColors.deepForest)
                        : (isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight),
                  ),
                if (!isCollapsed) ...[
                  const SizedBox(width: 14),
                  Expanded(
                    child: Text(
                      label,
                      style: TextStyle(
                        fontSize: 13.5,
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                        color: isSelected
                            ? (isDark ? AppColors.textPrimaryDark : AppColors.deepForest)
                            : (isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight),
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildShortcutItem(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 1.5),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9.5),
            child: Row(
              children: [
                Icon(
                  icon,
                  size: 18,
                  color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                ),
                if (!isCollapsed) ...[
                  const SizedBox(width: 14),
                  Expanded(
                    child: Text(
                      label,
                      style: TextStyle(
                        fontSize: 13,
                        color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
