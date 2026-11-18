import 'package:flutter/material.dart';
import '../../app/theme/app_colors.dart';

class StatBadge extends StatelessWidget {
  final String label;
  final IconData? icon;
  final Color? color;
  final Color? textColor;
  final bool isSuccess;
  final bool isError;
  final bool isWarning;

  const StatBadge({
    super.key,
    required this.label,
    this.icon,
    this.color,
    this.textColor,
    this.isSuccess = false,
    this.isError = false,
    this.isWarning = false,
  });

  @override
  Widget build(BuildContext context) {
    Color bg;
    Color fg;

    if (isSuccess) {
      bg = AppColors.success.withValues(alpha: 0.12);
      fg = AppColors.success;
    } else if (isError) {
      bg = AppColors.error.withValues(alpha: 0.12);
      fg = AppColors.error;
    } else if (isWarning) {
      bg = AppColors.warning.withValues(alpha: 0.12);
      fg = AppColors.warning;
    } else if (color != null) {
      bg = color!.withValues(alpha: 0.12);
      fg = textColor ?? color!;
    } else {
      bg = AppColors.surfaceSecondaryLight;
      fg = AppColors.textSecondaryLight;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 12, color: fg),
            const SizedBox(width: 4),
          ],
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: fg,
              letterSpacing: 0.1,
            ),
          ),
        ],
      ),
    );
  }
}
