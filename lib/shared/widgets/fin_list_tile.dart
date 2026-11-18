import 'package:flutter/material.dart';
import '../../app/theme/app_colors.dart';
import 'fin_animated_icon.dart';

/// Clean, flat, modern fintech list tile widget.
/// Replaces boxed card layouts with high-performance, responsive list items
/// featuring proper Row/Column/Expanded alignment and subtle micro-interactions.
class FinListTile extends StatelessWidget {
  final Widget? leading;
  final IconData? icon;
  final Color? iconColor;
  final Color? iconBackgroundColor;
  final double iconSize;
  final String? title;
  final String? subtitle;
  final Widget? titleWidget;
  final Widget? subtitleWidget;
  final String? trailingTitle;
  final String? trailingSubtitle;
  final Color? trailingTitleColor;
  final Widget? trailing;
  final Widget? bottomWidget;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final bool showDivider;
  final EdgeInsetsGeometry padding;
  final double indentDivider;

  const FinListTile({
    super.key,
    this.leading,
    this.icon,
    this.iconColor,
    this.iconBackgroundColor,
    this.iconSize = 18.0,
    this.title,
    this.subtitle,
    this.titleWidget,
    this.subtitleWidget,
    this.trailingTitle,
    this.trailingSubtitle,
    this.trailingTitleColor,
    this.trailing,
    this.bottomWidget,
    this.onTap,
    this.onLongPress,
    this.showDivider = true,
    this.padding = const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    this.indentDivider = 68.0,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    Widget? effectiveLeading = leading;
    if (effectiveLeading == null && icon != null) {
      effectiveLeading = FinAnimatedIcon(
        icon: icon!,
        size: iconSize,
        color: iconColor ?? (isDark ? AppColors.textPrimaryDark : AppColors.deepForest),
        backgroundColor: iconBackgroundColor ??
            (isDark ? AppColors.surfaceSecondaryDark : AppColors.surfaceSecondaryLight),
        backgroundSize: 40.0,
        borderRadius: 12.0,
      );
    }

    Widget? effectiveTrailing = trailing;
    if (effectiveTrailing == null && (trailingTitle != null || trailingSubtitle != null)) {
      effectiveTrailing = Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (trailingTitle != null)
            Text(
              trailingTitle!,
              style: TextStyle(
                fontSize: 14.0,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.3,
                color: trailingTitleColor ??
                    (isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight),
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          if (trailingSubtitle != null) ...[
            const SizedBox(height: 2),
            Text(
              trailingSubtitle!,
              style: TextStyle(
                fontSize: 11.5,
                fontWeight: FontWeight.w500,
                color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ],
      );
    }

    final tileContent = Padding(
      padding: padding,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (effectiveLeading != null) ...[
                effectiveLeading,
                const SizedBox(width: 14),
              ],
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    titleWidget ??
                        Text(
                          title ?? '',
                          style: TextStyle(
                            fontSize: 14.5,
                            fontWeight: FontWeight.w600,
                            letterSpacing: -0.2,
                            color: isDark
                                ? AppColors.textPrimaryDark
                                : AppColors.textPrimaryLight,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                    if (subtitleWidget != null || subtitle != null) ...[
                      const SizedBox(height: 3),
                      subtitleWidget ??
                          Text(
                            subtitle!,
                            style: TextStyle(
                              fontSize: 12.0,
                              fontWeight: FontWeight.w400,
                              color: isDark
                                  ? AppColors.textSecondaryDark
                                  : AppColors.textSecondaryLight,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                    ],
                  ],
                ),
              ),
              if (effectiveTrailing != null) ...[
                const SizedBox(width: 12),
                effectiveTrailing,
              ],
            ],
          ),
          if (bottomWidget != null) ...[
            const SizedBox(height: 10),
            bottomWidget!,
          ],
        ],
      ),
    );

    Widget item = Material(
      color: Colors.transparent,
      child: onTap != null || onLongPress != null
          ? InkWell(
              onTap: onTap,
              onLongPress: onLongPress,
              splashColor: AppColors.sage.withValues(alpha: 0.1),
              highlightColor: AppColors.sage.withValues(alpha: 0.05),
              child: tileContent,
            )
          : tileContent,
    );

    if (showDivider) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          item,
          Divider(
            height: 1,
            thickness: 0.8,
            indent: indentDivider,
            endIndent: 16,
            color: (isDark ? AppColors.borderDark : AppColors.borderLight)
                .withValues(alpha: 0.65),
          ),
        ],
      );
    }

    return item;
  }
}
