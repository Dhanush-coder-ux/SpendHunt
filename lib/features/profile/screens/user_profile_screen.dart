import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../app/theme/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/providers/finance_provider.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../shared/widgets/confirmation_dialog.dart';
import '../../../shared/widgets/fin_animated_icon.dart';
import '../../../shared/widgets/fin_list_tile.dart';
import '../../../shared/widgets/fin_section.dart';
import '../../../shared/widgets/section_header.dart';

class UserProfileScreen extends ConsumerWidget {
  const UserProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final finance = ref.watch(financeProvider);
    final profile = finance.profile;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final width = MediaQuery.of(context).size.width;
    final isDesktop = width >= AppConstants.tabletBreakpoint;

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      appBar: AppBar(
        title: const Text('My Profile', style: TextStyle(fontWeight: FontWeight.w700)),
        actions: [
          IconButton(
            onPressed: () => context.push('/settings'),
            icon: const Icon(LucideIcons.settings, size: 20),
            tooltip: 'App Settings',
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
                horizontal: isDesktop ? 32 : 18,
                vertical: 18,
              ),
              children: [
                // Profile Avatar & Name Section
                FinSection(
                  padding: const EdgeInsets.all(20),
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 58,
                          height: 58,
                          decoration: BoxDecoration(
                            color: AppColors.deepForest,
                            shape: BoxShape.circle,
                            border: Border.all(color: AppColors.warmBronze, width: 2),
                          ),
                          child: const Center(
                            child: Text(
                              'DK',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                profile.name,
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                  color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 3),
                              Text(
                                profile.email,
                                style: TextStyle(
                                  fontSize: 12.5,
                                  color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: AppColors.deepForest.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  'Pro Member • Currency: ${profile.currency}',
                                  style: const TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.deepForest,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 18),

                // Baseline Financial Metrics
                Row(
                  children: [
                    Expanded(
                      child: FinSection(
                        padding: const EdgeInsets.all(14),
                        children: [
                          const Text('Monthly Income', style: TextStyle(fontSize: 11, color: AppColors.textSecondaryLight)),
                          const SizedBox(height: 4),
                          Text(
                            CurrencyFormatter.format(profile.monthlyIncome, currencyCode: profile.currency),
                            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: FinSection(
                        padding: const EdgeInsets.all(14),
                        children: [
                          const Text('Budgeting Model', style: TextStyle(fontSize: 11, color: AppColors.textSecondaryLight)),
                          const SizedBox(height: 4),
                          Text(
                            profile.budgetingStyle,
                            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Navigation Shortcuts
                const SectionHeader(title: 'Financial Assets & Controls'),
                const SizedBox(height: 10),

                FinSection(
                  children: [
                    FinListTile(
                      onTap: () => context.push('/accounts'),
                      leading: const FinAnimatedIcon(
                        icon: LucideIcons.wallet,
                        size: 18,
                        color: AppColors.deepForest,
                        backgroundColor: Color(0x1F0C3B2E),
                        backgroundSize: 38,
                        borderRadius: 10,
                      ),
                      title: 'Linked Accounts',
                      subtitle: '${finance.accounts.length} bank accounts and cards',
                      trailing: const Icon(LucideIcons.chevronRight, size: 18, color: AppColors.textSecondaryLight),
                      showDivider: true,
                    ),
                    FinListTile(
                      onTap: () => context.push('/categories'),
                      leading: const FinAnimatedIcon(
                        icon: LucideIcons.shapes,
                        size: 18,
                        color: AppColors.sage,
                        backgroundColor: Color(0x1F8D9773),
                        backgroundSize: 38,
                        borderRadius: 10,
                      ),
                      title: 'Transaction Categories',
                      subtitle: '${finance.categories.length} income & expense categories',
                      trailing: const Icon(LucideIcons.chevronRight, size: 18, color: AppColors.textSecondaryLight),
                      showDivider: true,
                    ),
                    FinListTile(
                      onTap: () => context.push('/savings'),
                      leading: const FinAnimatedIcon(
                        icon: LucideIcons.target,
                        size: 18,
                        color: AppColors.goldenYellow,
                        backgroundColor: Color(0x1FFFBA00),
                        backgroundSize: 38,
                        borderRadius: 10,
                      ),
                      title: 'Savings Milestones',
                      subtitle: '${finance.savingsGoals.length} ongoing financial targets',
                      trailing: const Icon(LucideIcons.chevronRight, size: 18, color: AppColors.textSecondaryLight),
                      showDivider: true,
                    ),
                    FinListTile(
                      onTap: () => context.push('/investments'),
                      leading: const FinAnimatedIcon(
                        icon: LucideIcons.trendingUp,
                        size: 18,
                        color: AppColors.success,
                        backgroundColor: Color(0x1F548B68),
                        backgroundSize: 38,
                        borderRadius: 10,
                      ),
                      title: 'Investment Portfolio',
                      subtitle: '${finance.investments.length} tracked asset holdings',
                      trailing: const Icon(LucideIcons.chevronRight, size: 18, color: AppColors.textSecondaryLight),
                      showDivider: true,
                    ),
                    FinListTile(
                      onTap: () => context.push('/loans'),
                      leading: const FinAnimatedIcon(
                        icon: LucideIcons.landmark,
                        size: 18,
                        color: AppColors.warmBronze,
                        backgroundColor: Color(0x1FBB8A52),
                        backgroundSize: 38,
                        borderRadius: 10,
                      ),
                      title: 'Loans & EMI Liabilities',
                      subtitle: '${finance.loans.length} active repayment tenures',
                      trailing: const Icon(LucideIcons.chevronRight, size: 18, color: AppColors.textSecondaryLight),
                      showDivider: true,
                    ),
                    FinListTile(
                      onTap: () => context.push('/subscriptions'),
                      leading: const FinAnimatedIcon(
                        icon: LucideIcons.calendarClock,
                        size: 18,
                        color: AppColors.catUtilities,
                        backgroundColor: Color(0x1F4A6B82),
                        backgroundSize: 38,
                        borderRadius: 10,
                      ),
                      title: 'Bills & Subscriptions',
                      subtitle: '${finance.subscriptions.length} recurring schedules',
                      trailing: const Icon(LucideIcons.chevronRight, size: 18, color: AppColors.textSecondaryLight),
                      showDivider: false,
                    ),
                  ],
                ),
                const SizedBox(height: 22),

                // App Preferences
                const SectionHeader(title: 'Preferences & System'),
                const SizedBox(height: 10),

                FinSection(
                  children: [
                    FinListTile(
                      onTap: () => context.push('/settings'),
                      leading: const FinAnimatedIcon(
                        icon: LucideIcons.sliders,
                        size: 18,
                        color: AppColors.deepForest,
                        backgroundColor: Color(0x1F0C3B2E),
                        backgroundSize: 38,
                        borderRadius: 10,
                      ),
                      title: 'General Settings',
                      subtitle: 'Dark Forest theme, currency, security',
                      trailing: const Icon(LucideIcons.chevronRight, size: 18, color: AppColors.textSecondaryLight),
                      showDivider: true,
                    ),
                    FinListTile(
                      onTap: () => context.push('/health'),
                      leading: const FinAnimatedIcon(
                        icon: LucideIcons.heartPulse,
                        size: 18,
                        color: AppColors.success,
                        backgroundColor: Color(0x1F548B68),
                        backgroundSize: 38,
                        borderRadius: 10,
                      ),
                      title: 'Financial Health Score',
                      subtitle: 'Emergency cushion, debt ratio, wellness',
                      trailing: const Icon(LucideIcons.chevronRight, size: 18, color: AppColors.textSecondaryLight),
                      showDivider: true,
                    ),
                    FinListTile(
                      onTap: () => _showAboutDialog(context),
                      leading: const FinAnimatedIcon(
                        icon: LucideIcons.info,
                        size: 18,
                        color: AppColors.sage,
                        backgroundColor: Color(0x1F8D9773),
                        backgroundSize: 38,
                        borderRadius: 10,
                      ),
                      title: 'About SpendHunt',
                      subtitle: 'Version 1.0.0 • Architecture & Design System',
                      trailing: const Icon(LucideIcons.chevronRight, size: 18, color: AppColors.textSecondaryLight),
                      showDivider: true,
                    ),
                    FinListTile(
                      onTap: () async {
                        final confirmed = await ConfirmationDialog.show(
                          context,
                          title: 'Sign Out',
                          message: 'Are you sure you want to sign out?',
                          confirmLabel: 'Sign Out',
                          isDestructive: true,
                        );
                        if (confirmed == true && context.mounted) {
                          context.go('/sign-in');
                        }
                      },
                      leading: const FinAnimatedIcon(
                        icon: LucideIcons.logOut,
                        size: 18,
                        color: AppColors.error,
                        backgroundColor: Color(0x1FC76558),
                        backgroundSize: 38,
                        borderRadius: 10,
                      ),
                      title: 'Sign Out',
                      subtitle: 'Safely disconnect active session',
                      trailing: const Icon(LucideIcons.chevronRight, size: 18, color: AppColors.textSecondaryLight),
                      showDivider: false,
                    ),
                  ],
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showAboutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Row(
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                ),
                clipBehavior: Clip.antiAlias,
                child: Image.asset(
                  AppConstants.appLogo,
                  fit: BoxFit.cover,
                  errorBuilder: (c, e, s) => Image.asset(AppConstants.appLogoNormalized, fit: BoxFit.cover),
                ),
              ),
              const SizedBox(width: 10),
              const Text('SpendHunt'),
            ],
          ),
          content: const Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Tagline: "Your Money. Your Goals. Your Intelligence."',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
              ),
              SizedBox(height: 10),
              Text(
                'SpendHunt is a premium personal finance application designed with natural earthy green and bronze aesthetics, complete with local reactive state management, simulated intelligence, and financial health monitoring.',
                style: TextStyle(fontSize: 13, height: 1.4),
              ),
              SizedBox(height: 12),
              Text('Version: 1.0.0 (Flutter Frontend Phase)', style: TextStyle(fontSize: 12, color: AppColors.textSecondaryLight)),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }
}
