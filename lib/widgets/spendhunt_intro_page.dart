// spendhunt_intro_page.dart
//
// App intro / splash page:
//   1. the money-note fan builds up (plays once)
//   2. "SpendHunt" appears letter by letter
//   3. the tagline fades in, then onFinished() is called
//
// Requires money_fan_icon.dart in the same folder.

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'money_fan_icon.dart';

class SpendHuntIntroPage extends StatefulWidget {
  const SpendHuntIntroPage({
    super.key,
    required this.onFinished,
    this.appName = 'SpendHunt',
    this.tagline = 'Track. Hunt. Save.',
    this.holdAfterText = const Duration(milliseconds: 1200),
  });

  /// Called once when the intro ends (or when the user taps to skip).
  final VoidCallback onFinished;
  final String appName;
  final String tagline;

  /// How long to stay on screen after the name has appeared.
  final Duration holdAfterText;

  @override
  State<SpendHuntIntroPage> createState() => _SpendHuntIntroPageState();
}

class _SpendHuntIntroPageState extends State<SpendHuntIntroPage>
    with SingleTickerProviderStateMixin {
  static const _accent = Color(0xFF6BCB77);

  late final AnimationController _text;
  bool _finished = false;
  bool _canSkip = false;
  Timer? _skipTimer;

  @override
  void initState() {
    super.initState();
    _text = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _skipTimer = Timer(const Duration(milliseconds: 600), () {
      if (mounted) _canSkip = true;
    });
  }

  @override
  void dispose() {
    _skipTimer?.cancel();
    _text.dispose();
    super.dispose();
  }

  void _onFanDone() {
    if (!mounted) return;
    _text.forward().whenComplete(() async {
      await Future.delayed(widget.holdAfterText);
      _finish(force: true);
    });
  }

  void _finish({bool force = false}) {
    // Avoid accidental skipping from touch-release on mobile app launch
    if (!force && !_canSkip) {
      return;
    }
    if (_finished || !mounted) return;
    _finished = true;
    widget.onFinished();
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final iconSize = (width * 0.62).clamp(160.0, 300.0);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        systemNavigationBarColor: Colors.transparent,
        systemNavigationBarIconBrightness: Brightness.light,
        systemNavigationBarDividerColor: Colors.transparent,
      ),
      child: Scaffold(
        backgroundColor: Colors.black,
        body: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: _finish, // tap anywhere to skip
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                MoneyFanIcon(
                  size: iconSize,
                  loop: false,
                  duration: const Duration(milliseconds: 3200),
                  onCompleted: _onFanDone,
                ),
                const SizedBox(height: 28),
                AnimatedBuilder(
                  animation: _text,
                  builder: (context, _) => _buildName(),
                ),
                const SizedBox(height: 10),
                AnimatedBuilder(
                  animation: _text,
                  builder: (context, _) {
                    final p = Curves.easeOut.transform(
                        ((_text.value - 0.7) / 0.3).clamp(0.0, 1.0));
                    return Opacity(
                      opacity: p,
                      child: Text(
                        widget.tagline,
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.65),
                          fontSize: 15,
                          letterSpacing: 2,
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Letters fade + slide up one after another.
  /// First 5 letters ("Spend") are white, the rest ("Hunt") are green.
  Widget _buildName() {
    final name = widget.appName;
    final letters = <Widget>[];
    for (int i = 0; i < name.length; i++) {
      final start = i * 0.06;
      final end = start + 0.4;
      final p = Curves.easeOutCubic
          .transform(((_text.value - start) / (end - start)).clamp(0.0, 1.0));
      letters.add(
        Opacity(
          opacity: p,
          child: Transform.translate(
            offset: Offset(0, 18 * (1 - p)),
            child: Text(
              name[i],
              style: TextStyle(
                color: i < 5 ? Colors.white : _accent,
                fontSize: 44,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.5,
              ),
            ),
          ),
        ),
      );
    }
    return Row(mainAxisSize: MainAxisSize.min, children: letters);
  }
}
