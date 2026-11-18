import 'package:flutter/material.dart';
import '../../app/theme/app_colors.dart';

/// Clean, flat card container for fintech hero surfaces and panels.
/// Avoids heavy shadows and redundant nested borders.
class AppCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final VoidCallback? onTap;
  final Color? color;
  final Color? borderColor;
  final double borderRadius;
  final double? width;
  final double? height;
  final bool hasBorder;
  final bool isSelected;

  const AppCard({
    super.key,
    required this.child,
    this.padding,
    this.onTap,
    this.color,
    this.borderColor,
    this.borderRadius = 18.0,
    this.width,
    this.height,
    this.hasBorder = true,
    this.isSelected = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final defaultBg = isDark ? AppColors.surfaceDark : AppColors.surfaceLight;
    final defaultBorder = isDark ? AppColors.borderDark : AppColors.borderLight;

    final effectiveBorderColor = isSelected
        ? AppColors.deepForest
        : (borderColor ?? (hasBorder ? defaultBorder.withValues(alpha: 0.8) : Colors.transparent));

    final effectiveCard = Container(
      width: width,
      height: height,
      padding: padding ?? const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color ?? defaultBg,
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(
          color: effectiveBorderColor,
          width: isSelected ? 1.6 : 1.0,
        ),
      ),
      child: child,
    );

    if (onTap != null) {
      return Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(borderRadius),
          splashColor: AppColors.sage.withValues(alpha: 0.1),
          highlightColor: AppColors.sage.withValues(alpha: 0.05),
          child: effectiveCard,
        ),
      );
    }

    return effectiveCard;
  }
}
