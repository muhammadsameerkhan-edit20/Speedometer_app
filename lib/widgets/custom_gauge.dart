import 'dart:math';
import 'package:flutter/material.dart';

class GaugePainter extends CustomPainter {
  final double speed; // 0..240
  GaugePainter(this.speed);

  double _deg2rad(double d) => d * pi / 180.0;

  // ✅ Full 360° arc (but with a small gap to separate 0 and 240)
  double _angleFor(double value) {
    final startDeg = -90.0; // start at top
    final sweepDeg = 360.0;
    final deg = startDeg + (value / 240.0) * sweepDeg;
    return _deg2rad(deg);
  }

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = min(size.width / 2, size.height / 2) - 30; // bigger circle

    // ===== Outer ring =====
    final outerGlowPaint = Paint()
      ..shader = SweepGradient(
        colors: [Colors.red.shade900, Colors.redAccent, Colors.red.shade900],
      ).createShader(Rect.fromCircle(center: center, radius: radius))
      ..style = PaintingStyle.stroke
      ..strokeWidth = 20
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 14);

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      _deg2rad(-90),
      _deg2rad(360),
      false,
      outerGlowPaint,
    );

    // ===== Inner ring =====
    final innerGlowPaint = Paint()
      ..shader = SweepGradient(
        colors: [Colors.redAccent, Colors.red.shade700, Colors.redAccent],
      ).createShader(Rect.fromCircle(center: center, radius: radius - 40))
      ..style = PaintingStyle.stroke
      ..strokeWidth = 16
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12);

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius - 40),
      _deg2rad(-90),
      _deg2rad(360),
      false,
      innerGlowPaint,
    );

    // ===== Ticks & digits =====
    for (int v = 0; v <= 240; v++) {
      final angle = _angleFor(v.toDouble());

      final isMajor = v % 20 == 0;
      final isMedium = !isMajor && v % 10 == 0;
      final len = isMajor ? 20.0 : (isMedium ? 12.0 : 6.0);

      // tick
      final p1 = Offset(
        center.dx + (radius - len) * cos(angle),
        center.dy + (radius - len) * sin(angle),
      );
      final p2 = Offset(
        center.dx + radius * cos(angle),
        center.dy + radius * sin(angle),
      );
      final tickPaint = Paint()
        ..color = Colors.white
        ..strokeWidth = isMajor ? 3 : 1.5;
      canvas.drawLine(p1, p2, tickPaint);

      if (isMajor) {
        // ===== digits (moved outward) =====
        final tp = TextPainter(
          text: TextSpan(
            text: v.toString(),
            style: const TextStyle(
              color: Colors.greenAccent,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          textDirection: TextDirection.ltr,
        )..layout();

        final labelRadius = radius + 25; // pushed outside arc
        final off = Offset(
          center.dx + labelRadius * cos(angle) - tp.width / 2,
          center.dy + labelRadius * sin(angle) - tp.height / 2,
        );
        tp.paint(canvas, off);
      }
    }

    // ===== Needle =====
    final clamped = speed.clamp(0, 240);
    final na = _angleFor(clamped.toDouble());

    final path = Path()
      ..moveTo(center.dx, center.dy)
      ..lineTo(
        center.dx + 20 * cos(na - 0.5),
        center.dy + 20 * sin(na - 0.5),
      )
      ..lineTo(
        center.dx + (radius - 60) * cos(na),
        center.dy + (radius - 60) * sin(na),
      )
      ..close();

    final glowPaint = Paint()
      ..color = Colors.yellowAccent.withOpacity(0.6)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 20);
    canvas.drawPath(path, glowPaint);

    final needlePaint = Paint()
      ..shader = const LinearGradient(
        colors: [Colors.yellowAccent, Colors.orange],
      ).createShader(Rect.fromCircle(center: center, radius: 40));
    canvas.drawPath(path, needlePaint);

    // ===== Center hub =====
    final hubGlow = Paint()
      ..color = Colors.yellowAccent.withOpacity(0.6)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 20);
    canvas.drawCircle(center, 15, hubGlow);

    final hubPaint = Paint()..color = Colors.orangeAccent;
    canvas.drawCircle(center, 8, hubPaint);

    // ===== Center readout =====
    final t = TextPainter(
      text: TextSpan(
        text: clamped.toStringAsFixed(0),
        style: const TextStyle(
          color: Colors.white,
          fontSize: 28,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    t.paint(canvas, center.translate(-t.width / 2, -18));

    final unit = TextPainter(
      text: const TextSpan(
        text: 'Km/h',
        style: TextStyle(color: Colors.white, fontSize: 16),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    unit.paint(canvas, center.translate(-unit.width / 2, 16));
  }

  @override
  bool shouldRepaint(covariant GaugePainter old) => old.speed != speed;
}
