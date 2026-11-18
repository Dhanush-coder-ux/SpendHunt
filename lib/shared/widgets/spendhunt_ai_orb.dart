import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/providers/ai_assistant_provider.dart';
import 'money_fan_icon.dart';

export 'money_fan_icon.dart';

/// SpendHunt AI Animated Icon powered by native MoneyFanIcon CustomPainter.
/// Replaces previous blue animation with the custom money-fan note animation.
class SpendHuntAIOrb extends ConsumerWidget {
  /// Dimension of the icon (default 36.0px).
  final double size;

  /// Optional manual state override. If null, reactively connects to [aiAssistantProvider].
  final SpendHuntAIState? state;

  /// Whether to auto-listen to the global AI assistant state. Default true.
  final bool autoConnectState;

  /// Optional tap callback.
  final VoidCallback? onTap;

  /// Whether to show a subtle ambient glow behind the icon.
  final bool showGlow;

  /// Currency symbol printed in the note centers ('₹', '$', etc.).
  final String currencySymbol;

  const SpendHuntAIOrb({
    super.key,
    this.size = 36.0,
    this.state,
    this.autoConnectState = true,
    this.onTap,
    this.showGlow = false,
    this.currencySymbol = '₹',
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final SpendHuntAIState effectiveState = state ??
        (autoConnectState
            ? ref.watch(aiAssistantProvider.select((s) => s.aiState))
            : SpendHuntAIState.idle);

    // Dynamic duration based on AI state
    Duration duration = const Duration(milliseconds: 3600);
    bool shouldAnimate = true;

    switch (effectiveState) {
      case SpendHuntAIState.idle:
        duration = const Duration(milliseconds: 3600);
        shouldAnimate = true;
        break;
      case SpendHuntAIState.active:
        duration = const Duration(milliseconds: 2200);
        shouldAnimate = true;
        break;
      case SpendHuntAIState.thinking:
        // Accelerated animation while AI is evaluating
        duration = const Duration(milliseconds: 1800);
        shouldAnimate = true;
        break;
      case SpendHuntAIState.response:
        duration = const Duration(milliseconds: 1400);
        shouldAnimate = true;
        break;
      case SpendHuntAIState.error:
        shouldAnimate = false;
        break;
    }

    Widget content = MoneyFanIcon(
      size: size,
      animate: shouldAnimate,
      duration: duration,
      currencySymbol: currencySymbol,
      showGlow: showGlow || effectiveState == SpendHuntAIState.active,
    );

    if (onTap != null) {
      return GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          HapticFeedback.lightImpact();
          onTap?.call();
        },
        child: content,
      );
    }

    return content;
  }
}

/// Legacy alias mapping to [SpendHuntAIOrb]
typedef SpendHuntAIIcon = SpendHuntAIOrb;
