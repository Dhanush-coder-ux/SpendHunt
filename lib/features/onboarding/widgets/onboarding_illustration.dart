import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import '../../../app/theme/app_colors.dart';

/// Premium animated Lottie illustration for SpendHunt onboarding.
///
/// Features:
/// - Starts animation automatically when [isActive] is true.
/// - Seamless continuous looping while the page is visible.
/// - Automatically pauses animation when page is inactive to save GPU/CPU cycles.
/// - Graceful neutral fallback placeholder when the asset is loading or missing.
/// - Proper disposal of [AnimationController] to prevent memory leaks.
class OnboardingIllustration extends StatefulWidget {
  final String assetPath;
  final bool isActive;
  final double size;

  const OnboardingIllustration({
    super.key,
    required this.assetPath,
    required this.isActive,
    this.size = 280.0,
  });

  @override
  State<OnboardingIllustration> createState() => _OnboardingIllustrationState();
}

class _OnboardingIllustrationState extends State<OnboardingIllustration>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  bool _isLoaded = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this);
  }

  @override
  void didUpdateWidget(covariant OnboardingIllustration oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isActive != oldWidget.isActive) {
      if (widget.isActive) {
        if (_isLoaded && !_controller.isAnimating) {
          _controller.repeat();
        }
      } else {
        if (_controller.isAnimating) {
          _controller.stop();
        }
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: Center(
        child: Lottie.asset(
          widget.assetPath,
          controller: _controller,
          fit: BoxFit.contain,
          alignment: Alignment.center,
          onLoaded: (composition) {
            if (!mounted) return;
            _controller.duration = composition.duration;
            _isLoaded = true;
            if (widget.isActive) {
              _controller.repeat();
            }
          },
          errorBuilder: (context, error, stackTrace) {
            // Neutral placeholder if the animation asset is not yet available
            return _buildPlaceholder(context);
          },
          frameBuilder: (context, child, composition) {
            if (composition == null) {
              return _buildPlaceholder(context);
            }
            return child;
          },
        ),
      ),
    );
  }

  Widget _buildPlaceholder(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      width: widget.size * 0.75,
      height: widget.size * 0.75,
      decoration: BoxDecoration(
        color: isDark
            ? AppColors.surfaceSecondaryDark.withValues(alpha: 0.6)
            : AppColors.surfaceSecondaryLight.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(24),
      ),
    );
  }
}
