import 'package:flutter/material.dart';
import '../../app/theme/app_colors.dart';

/// Flat, clean grouping container for modern fintech interfaces.
/// Replaces multiple individual boxed cards with one unified, calm, flat section.
class FinSection extends StatelessWidget {
  final List<Widget>? children;
  final Widget? child;
  final EdgeInsetsGeometry? margin;
  final EdgeInsetsGeometry? padding;
  final Color? backgroundColor;
  final double borderRadius;
  final bool hasBorder;

  const FinSection({
    super.key,
    this.children,
    this.child,
    this.margin,
    this.padding,
    this.backgroundColor,
    this.borderRadius = 16.0,
    this.hasBorder = true,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final defaultBg = isDark ? AppColors.surfaceDark : AppColors.surfaceLight;
    final defaultBorder = isDark ? AppColors.borderDark : AppColors.borderLight;

    return Container(
      margin: margin,
      padding: padding ?? EdgeInsets.zero,
      decoration: BoxDecoration(
        color: backgroundColor ?? defaultBg,
        borderRadius: BorderRadius.circular(borderRadius),
        border: hasBorder
            ? Border.all(
                color: defaultBorder.withValues(alpha: 0.8),
                width: 1.0,
              )
            : null,
      ),
      clipBehavior: Clip.antiAlias,
      child: child ??
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: children ?? const [],
          ),
    );
  }
}
