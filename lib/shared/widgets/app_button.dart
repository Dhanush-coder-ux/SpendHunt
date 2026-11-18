import 'package:flutter/material.dart';
import '../../app/theme/app_colors.dart';

enum AppButtonVariant {
  primary,
  secondary,
  outlined,
  ghost,
  danger,
}

class AppButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final AppButtonVariant variant;
  final bool isLoading;
  final double? width;
  final double height;
  final double borderRadius;
  final EdgeInsetsGeometry? padding;

  const AppButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.variant = AppButtonVariant.primary,
    this.isLoading = false,
    this.width,
    this.height = 48.0,
    this.borderRadius = 14.0,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    Color bg;
    Color fg;
    BorderSide border = BorderSide.none;

    switch (variant) {
      case AppButtonVariant.primary:
        bg = AppColors.deepForest;
        fg = Colors.white;
        break;
      case AppButtonVariant.secondary:
        bg = isDark ? AppColors.surfaceSecondaryDark : AppColors.surfaceSecondaryLight;
        fg = isDark ? AppColors.textPrimaryDark : AppColors.deepForest;
        break;
      case AppButtonVariant.outlined:
        bg = Colors.transparent;
        fg = isDark ? AppColors.textPrimaryDark : AppColors.deepForest;
        border = BorderSide(
          color: isDark ? AppColors.borderDark : AppColors.borderLight,
          width: 1.2,
        );
        break;
      case AppButtonVariant.ghost:
        bg = Colors.transparent;
        fg = isDark ? AppColors.sage : AppColors.deepForest;
        break;
      case AppButtonVariant.danger:
        bg = AppColors.error.withValues(alpha: 0.12);
        fg = AppColors.error;
        border = BorderSide(color: AppColors.error.withValues(alpha: 0.3), width: 1);
        break;
    }

    Widget content;
    if (isLoading) {
      content = SizedBox(
        width: 20,
        height: 20,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(fg),
        ),
      );
    } else if (icon != null) {
      content = Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 18, color: fg),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              label,
              style: TextStyle(
                color: fg,
                fontSize: 14.0,
                fontWeight: FontWeight.w600,
                letterSpacing: -0.2,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      );
    } else {
      content = Text(
        label,
        style: TextStyle(
          color: fg,
          fontSize: 14.0,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.2,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      );
    }

    return SizedBox(
      width: width,
      height: height,
      child: Material(
        color: bg,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadius),
          side: border,
        ),
        child: InkWell(
          onTap: isLoading ? null : onPressed,
          borderRadius: BorderRadius.circular(borderRadius),
          splashColor: fg.withValues(alpha: 0.1),
          highlightColor: fg.withValues(alpha: 0.05),
          child: Center(
            child: Padding(
              padding: padding ?? const EdgeInsets.symmetric(horizontal: 12),
              child: content,
            ),
          ),
        ),
      ),
    );
  }
}
