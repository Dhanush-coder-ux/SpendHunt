import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../app/theme/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/models/notification_item.dart';
import '../../../core/providers/notification_provider.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../../shared/widgets/fin_animated_icon.dart';
import '../../../shared/widgets/fin_list_tile.dart';
import '../../../shared/widgets/fin_section.dart';

class NotificationsScreen extends ConsumerWidget {
  const NotificationsScreen({super.key});

  IconData _getCategoryIcon(NotificationCategory category) {
    switch (category) {
      case NotificationCategory.budgetAlert:
        return LucideIcons.pieChart;
      case NotificationCategory.upcomingPayment:
        return LucideIcons.calendarClock;
      case NotificationCategory.savingsMilestone:
        return LucideIcons.trophy;
      case NotificationCategory.aiInsight:
        return LucideIcons.sparkles;
      case NotificationCategory.transaction:
        return LucideIcons.arrowDownLeft;
    }
  }

  Color _getCategoryColor(NotificationCategory category) {
    switch (category) {
      case NotificationCategory.budgetAlert:
        return AppColors.warning;
      case NotificationCategory.upcomingPayment:
        return AppColors.info;
      case NotificationCategory.savingsMilestone:
        return AppColors.goldenYellow;
      case NotificationCategory.aiInsight:
        return AppColors.warmBronze;
      case NotificationCategory.transaction:
        return AppColors.success;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifications = ref.watch(notificationProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final width = MediaQuery.of(context).size.width;
    final isDesktop = width >= AppConstants.tabletBreakpoint;

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      appBar: AppBar(
        title: const Text('Notifications', style: TextStyle(fontWeight: FontWeight.w700)),
        actions: [
          if (notifications.isNotEmpty) ...[
            TextButton(
              onPressed: () {
                ref.read(notificationProvider.notifier).markAllAsRead();
              },
              child: const Text('Mark all read', style: TextStyle(fontSize: 12.5)),
            ),
            IconButton(
              onPressed: () {
                ref.read(notificationProvider.notifier).clearAll();
              },
              icon: const Icon(LucideIcons.trash2, size: 18),
              tooltip: 'Clear All',
            ),
          ],
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 720),
            child: notifications.isEmpty
                ? const EmptyState(
                    title: 'No notifications',
                    description: 'You are all caught up on budget alerts, payments, and AI insights.',
                    icon: LucideIcons.bellOff,
                  )
                : ListView(
                    padding: EdgeInsets.symmetric(
                      horizontal: isDesktop ? 24 : 16,
                      vertical: 14,
                    ),
                    children: [
                      FinSection(
                        children: List.generate(notifications.length, (index) {
                          final item = notifications[index];
                          final isLast = index == notifications.length - 1;
                          final color = _getCategoryColor(item.category);
                          final icon = _getCategoryIcon(item.category);

                          return FinListTile(
                            onTap: () {
                              ref.read(notificationProvider.notifier).markAsRead(item.id);
                              final targetRoute = item.route ?? item.actionRoute;
                              if (targetRoute != null) {
                                context.push(targetRoute);
                              }
                            },
                            leading: FinAnimatedIcon(
                              icon: icon,
                              size: 18,
                              color: color,
                              backgroundColor: color.withValues(alpha: 0.12),
                              backgroundSize: 40,
                              borderRadius: 12,
                            ),
                            titleWidget: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    item.title,
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: item.isRead ? FontWeight.w500 : FontWeight.w700,
                                      color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                if (!item.isRead) ...[
                                  const SizedBox(width: 6),
                                  Container(
                                    width: 7,
                                    height: 7,
                                    decoration: const BoxDecoration(
                                      color: AppColors.goldenYellow,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                            subtitle: item.message,
                            trailingSubtitle: DateFormatter.formatRelative(item.timestamp),
                            showDivider: !isLast,
                          );
                        }),
                      ),
                      const SizedBox(height: 40),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}
