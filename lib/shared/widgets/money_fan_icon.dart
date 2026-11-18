// money_fan_icon.dart
//
// Money-note "fan" animation for use as an AI icon / loading indicator.
// No assets, no packages: everything is drawn with CustomPainter.
//
// Animation (one loop):
//   1. a single note appears in the center
//   2. it shrinks and settles into the ring position
//   3. the remaining notes swing out one by one to form the round fan
//   4. the fan holds, makes a small turn, then fades and restarts

import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../core/providers/ai_assistant_provider.dart';

class MoneyFanIcon extends StatefulWidget {
  const MoneyFanIcon({
    super.key,
    this.size = 36,
    this.animate = true,
    this.noteCount = 20,
    this.duration = const Duration(milliseconds: 3600),
    this.backgroundColor,
    this.currencySymbol = '₹',
    this.state,
    this.autoConnectState = true,
    this.showGlow = false,
  });

  /// Width and height of the icon in logical pixels.
  final double size;

  /// true = looping animation, false = static full fan.
  final bool animate;

  /// Number of notes in the circle (minimum 3).
  final int noteCount;

  /// Duration of one full loop.
  final Duration duration;

  /// Optional background (e.g. black). Transparent by default.
  final Color? backgroundColor;

  /// Currency symbol printed in the note center ('₹', '$', etc.).
  final String currencySymbol;

  /// Optional AI state override.
  final SpendHuntAIState? state;

  /// Auto-connect to global AI assistant state.
  final bool autoConnectState;

  /// Whether to show a subtle ambient glow behind the fan.
  final bool showGlow;

  @override
  State<MoneyFanIcon> createState() => _MoneyFanIconState();
}

class _MoneyFanIconState extends State<MoneyFanIcon>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late _FanPainter _painter;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration);
    _painter = _buildPainter();
    if (widget.animate) _controller.repeat();
  }

  _FanPainter _buildPainter() => _FanPainter(
        controller: _controller,
        animate: widget.animate,
        noteCount: math.max(3, widget.noteCount),
        symbol: widget.currencySymbol,
      );

  @override
  void didUpdateWidget(covariant MoneyFanIcon old) {
    super.didUpdateWidget(old);
    if (old.duration != widget.duration) {
      _controller.duration = widget.duration;
    }
    if (old.animate != widget.animate ||
        old.noteCount != widget.noteCount ||
        old.currencySymbol != widget.currencySymbol) {
      _painter = _buildPainter();
    }
    if (widget.animate && !_controller.isAnimating) {
      _controller.repeat();
    } else if (!widget.animate && _controller.isAnimating) {
      _controller.stop();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Widget content = RepaintBoundary(
      child: SizedBox(
        width: widget.size,
        height: widget.size,
        child: DecoratedBox(
          decoration: BoxDecoration(color: widget.backgroundColor),
          child: CustomPaint(painter: _painter),
        ),
      ),
    );

    if (widget.showGlow) {
      content = Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFCBBD93).withValues(alpha: 0.35),
              blurRadius: widget.size * 0.45,
              spreadRadius: widget.size * 0.08,
            ),
          ],
        ),
        child: content,
      );
    }

    return content;
  }
}

class _FanPainter extends CustomPainter {
  _FanPainter({
    required this.controller,
    required this.animate,
    required this.noteCount,
    required this.symbol,
  }) : super(repaint: controller);

  final AnimationController controller;
  final bool animate;
  final int noteCount;
  final String symbol;

  // Timeline (0..1 of one loop)
  static const double _fadeIn = 0.04;
  static const double _moveStart = 0.07;
  static const double _buildStart = 0.14;
  static const double _buildEnd = 0.68;
  static const double _spinStart = 0.76;
  static const double _spinEnd = 0.92;
  static const double _holdT = 0.70; // static pose

  // Colors tuned to Night Sands & Fintech Currency notes
  static const _border = Color(0xFF80775C);     // Night taupe
  static const _face = Color(0xFFFAE8B4);       // Light sand cream note face
  static const _oval = Color(0xFFCBBD93);       // Warm sand center oval
  static const _sealDark = Color(0xFF574A24);   // Deep dark olive seal
  static const _sealGreen = Color(0xFF5B8A68);  // Olive sage green seal
  static const _greenLine = Color(0xFF5B8A68);  // Subtle green tick
  static const _dollarColor = Color(0xFF574A24); // Espresso dark bronze symbol

  TextPainter? _tp;
  double _tpSize = 0;

  TextPainter _dollar(double fontSize) {
    if (_tp == null || _tpSize != fontSize) {
      _tp = TextPainter(
        text: TextSpan(
          text: symbol,
          style: TextStyle(
            fontSize: fontSize,
            fontWeight: FontWeight.w900,
            color: _dollarColor,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      _tpSize = fontSize;
    }
    return _tp!;
  }

  double _ease(double t) => t * t * (3 - 2 * t);
  double _clamp01(double v) => v < 0 ? 0 : (v > 1 ? 1 : v);

  @override
  void paint(Canvas canvas, Size size) {
    final px = math.min(size.width, size.height);
    final u = px / 720.0; // all geometry is designed on a 720 canvas
    final t = animate ? controller.value : _holdT;
    final n = noteCount;
    final step = 2 * math.pi / n;
    final ring = 135 * u;
    final detailed = px >= 26;

    canvas.save();
    canvas.translate(size.width / 2, size.height / 2);

    // Global fade in / out for a clean loop restart
    double opacity = 1;
    if (animate) {
      if (t < _fadeIn) {
        opacity = t / _fadeIn;
      } else if (t > _spinEnd) {
        opacity = _clamp01((1 - t) / (1 - _spinEnd));
      }
    }
    final layered = opacity < 1;
    if (layered) {
      canvas.saveLayer(
        Rect.fromCenter(
            center: Offset.zero, width: size.width, height: size.height),
        Paint()..color = Color.fromARGB((opacity * 255).round(), 255, 255, 255),
      );
    }

    if (t < _buildStart) {
      // Phase 1-2: single note, then settle into ring position
      final m = _ease(_clamp01((t - _moveStart) / (_buildStart - _moveStart)));
      _drawNote(canvas, u, detailed,
          posAngle: 0, radius: ring * m, rotation: 0, scale: 1.5 - 0.5 * m);
    } else {
      // Phase 3-4: build one by one, then spin
      final spinOff =
          _ease(_clamp01((t - _spinStart) / (_spinEnd - _spinStart))) * step;
      _drawNote(canvas, u, detailed,
          posAngle: spinOff, radius: ring, rotation: spinOff, scale: 1);

      final span = _buildEnd - _buildStart;
      final dur = span / (n - 1) * 2.5; // overlap so it feels fluid
      for (int i = 1; i < n; i++) {
        final s = _buildStart + (span - dur) * (i - 1) / (n - 2);
        final p = _clamp01((t - s) / dur);
        if (p <= 0) continue;
        final a = step * i * _ease(p) + spinOff;
        _drawNote(canvas, u, detailed,
            posAngle: a, radius: ring, rotation: a, scale: 1);
      }
    }

    if (layered) canvas.restore();
    canvas.restore();
  }

  void _drawNote(
    Canvas canvas,
    double u,
    bool detailed, {
    required double posAngle,
    required double radius,
    required double rotation,
    required double scale,
  }) {
    canvas.save();
    canvas.translate(
        radius * math.cos(posAngle), radius * math.sin(posAngle));
    canvas.rotate(rotation);
    canvas.scale(scale);

    final fill = Paint()..style = PaintingStyle.fill;
    final stroke = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2 * u
      ..color = _border;

    // Outer border + face
    final outer = RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset.zero, width: 300 * u, height: 140 * u),
        Radius.circular(14 * u));
    canvas.drawRRect(outer, fill..color = _border);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
          Rect.fromCenter(
              center: Offset.zero, width: 290 * u, height: 130 * u),
          Radius.circular(10 * u)),
      fill..color = _face,
    );

    // Center oval
    canvas.drawCircle(Offset.zero, 42 * u, fill..color = _oval);

    // Side seals
    canvas.drawCircle(Offset(-102 * u, 0), 14 * u, fill..color = _sealDark);
    canvas.drawCircle(Offset(102 * u, 0), 14 * u, fill..color = _sealGreen);

    if (detailed) {
      // Inner outline
      canvas.drawRRect(
        RRect.fromRectAndRadius(
            Rect.fromCenter(
                center: Offset.zero, width: 272 * u, height: 112 * u),
            Radius.circular(6 * u)),
        stroke,
      );

      // Green ticks (top-left and bottom-right)
      final tick = Paint()
        ..color = _greenLine
        ..strokeWidth = 2 * u;
      for (int i = 0; i < 8; i++) {
        final x = -120 * u + i * 7 * u;
        canvas.drawLine(Offset(x, -50 * u), Offset(x, -36 * u), tick);
        canvas.drawLine(Offset(-x, 50 * u), Offset(-x, 36 * u), tick);
      }

      // Bottom grey lines
      final line = Paint()
        ..color = _border
        ..strokeWidth = 2 * u;
      for (int k = 0; k < 3; k++) {
        final y = (30 + k * 8) * u;
        canvas.drawLine(Offset(-60 * u, y), Offset(60 * u, y), line);
      }

      // Dollar / Currency sign
      final tp = _dollar(52 * u);
      tp.paint(canvas, Offset(-tp.width / 2, -tp.height / 2));
    }

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _FanPainter old) =>
      old.animate != animate ||
      old.noteCount != noteCount ||
      old.symbol != symbol;
}
