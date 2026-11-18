import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../app/theme/app_colors.dart';

/// Premium fintech micro-interaction animated icon widget.
/// Provides subtle entrance transitions, interactive tactile feedback,
/// and optional gentle breathing pulses for live states without expensive controllers.
class FinAnimatedIcon extends StatefulWidget {
  final IconData icon;
  final double size;
  final Color? color;
  final Color? backgroundColor;
  final double backgroundSize;
  final double borderRadius;
  final bool pulse;
  final bool animateEntry;
  final VoidCallback? onTap;
  final Duration animationDuration;

  const FinAnimatedIcon({
    super.key,
    required this.icon,
    this.size = 20.0,
    this.color,
    this.backgroundColor,
    this.backgroundSize = 40.0,
    this.borderRadius = 12.0,
    this.pulse = false,
    this.animateEntry = true,
    this.onTap,
    this.animationDuration = const Duration(milliseconds: 220),
  });

  @override
  State<FinAnimatedIcon> createState() => _FinAnimatedIconState();
}

class _FinAnimatedIconState extends State<FinAnimatedIcon> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final effectiveColor = widget.color ?? AppColors.deepForest;

    Widget iconWidget = Icon(
      widget.icon,
      size: widget.size,
      color: effectiveColor,
    );

    if (widget.animateEntry) {
      iconWidget = iconWidget
          .animate()
          .scale(
            begin: const Offset(0.88, 0.88),
            end: const Offset(1.0, 1.0),
            duration: widget.animationDuration,
            curve: Curves.easeOutCubic,
          )
          .fadeIn(
            duration: widget.animationDuration,
            curve: Curves.easeOut,
          );
    }

    if (widget.pulse) {
      iconWidget = iconWidget
          .animate(onPlay: (controller) => controller.repeat(reverse: true))
          .scaleXY(
            begin: 1.0,
            end: 1.08,
            duration: 1200.ms,
            curve: Curves.easeInOut,
          );
    }

    Widget content = iconWidget;

    // Wrap in container if background color is specified
    if (widget.backgroundColor != null) {
      content = Container(
        width: widget.backgroundSize,
        height: widget.backgroundSize,
        decoration: BoxDecoration(
          color: widget.backgroundColor,
          borderRadius: BorderRadius.circular(widget.borderRadius),
        ),
        child: Center(child: iconWidget),
      );
    }

    // Apply tactile spring feedback on tap
    if (widget.onTap != null) {
      return GestureDetector(
        onTapDown: (_) => setState(() => _isPressed = true),
        onTapUp: (_) {
          setState(() => _isPressed = false);
          widget.onTap?.call();
        },
        onTapCancel: () => setState(() => _isPressed = false),
        child: AnimatedScale(
          scale: _isPressed ? 0.92 : 1.0,
          duration: const Duration(milliseconds: 100),
          curve: Curves.easeOutCubic,
          child: content,
        ),
      );
    }

    return content;
  }
}
