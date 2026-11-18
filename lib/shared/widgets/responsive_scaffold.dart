import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../core/constants/app_constants.dart';
import '../../core/providers/notification_provider.dart';
import '../../app/theme/app_colors.dart';
import 'app_bottom_navigation.dart';
import 'app_sidebar.dart';

class ResponsiveScaffold extends ConsumerWidget {
  final int currentIndex;
  final Widget child;

  const ResponsiveScaffold({
    super.key,
    required this.currentIndex,
    required this.child,
  });

  void _onNavigationIndexChanged(BuildContext context, int index) {
    switch (index) {
      case 0:
        context.go('/dashboard');
        break;
      case 1:
        context.go('/transactions');
        break;
      case 2:
        context.go('/budgets');
        break;
      case 3:
        context.go('/ai');
        break;
      case 4:
        context.go('/profile');
        break;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final width = MediaQuery.of(context).size.width;
    final isDesktop = width >= AppConstants.tabletBreakpoint;
    final unreadCount = ref.watch(unreadNotificationCountProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (isDesktop) {
      return Scaffold(
        body: Row(
          children: [
            AppSidebar(
              currentIndex: currentIndex,
              onSelectIndex: (idx) => _onNavigationIndexChanged(context, idx),
              onNavigate: (route) => context.push(route),
            ),
            Expanded(
              child: Column(
                children: [
                  // Top Desktop Header
                  Container(
                    height: 64,
                    padding: const EdgeInsets.symmetric(horizontal: 28),
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
                      border: Border(
                        bottom: BorderSide(
                          color: isDark ? AppColors.borderDark : AppColors.borderLight,
                          width: 1,
                        ),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _getTitleForIndex(currentIndex),
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            letterSpacing: -0.2,
                            color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                          ),
                        ),
                        Row(
                          children: [
                            IconButton(
                              onPressed: () => context.push('/notifications'),
                              icon: Badge(
                                isLabelVisible: unreadCount > 0,
                                label: Text(
                                  unreadCount.toString(),
                                  style: const TextStyle(fontSize: 10, color: Colors.white),
                                ),
                                backgroundColor: AppColors.error,
                                child: Icon(
                                  LucideIcons.bell,
                                  size: 20,
                                  color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            InkWell(
                              onTap: () => context.go('/profile'),
                              borderRadius: BorderRadius.circular(20),
                              child: Container(
                                width: 34,
                                height: 34,
                                decoration: BoxDecoration(
                                  color: AppColors.deepForest,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: AppColors.warmBronze,
                                    width: 1.5,
                                  ),
                                ),
                                child: const Center(
                                  child: Text(
                                    'DK',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: AppConstants.maxContentWidth),
                        child: child,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    // Mobile & Tablet Layout
    return Scaffold(
      body: child,
      bottomNavigationBar: AppBottomNavigation(
        currentIndex: currentIndex,
        onTap: (idx) => _onNavigationIndexChanged(context, idx),
      ),
    );
  }

  String _getTitleForIndex(int index) {
    switch (index) {
      case 0:
        return 'SpendHunt Overview';
      case 1:
        return 'Activity & Transactions';
      case 2:
        return 'Budgets & Expense Planning';
      case 3:
        return 'SpendHunt AI Intelligence';
      case 4:
        return 'Account & Settings';
      default:
        return 'SpendHunt';
    }
  }
}
