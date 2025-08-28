import 'dart:math';
import 'package:flutter/material.dart';

class GaugePainter extends CustomPainter {
  final double speed; // expected 0..240
  GaugePainter(this.speed);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = min(size.width / 2, size.height / 2) - 20;

    // ===== Red glowing circular ring =====
    final rect = Rect.fromCircle(center: center, radius: radius);
    final glowPaint = Paint()
      ..shader = SweepGradient(
        colors: [Colors.red.shade900, Colors.redAccent, Colors.red.shade900],
      ).createShader(rect)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 22
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10);
    canvas.drawCircle(center, radius, glowPaint);

    // ===== Gauge Parameters =====
    const maxSpeed = 240;
    const startAngle = 5 * pi / 4; // 225° (0 at left-bottom)
    const sweepAngle = 2 * pi;     // 360° full circle
    const majorStep = 12;          // label step

    // ===== Draw Ticks and Labels =====
    for (int value = 0; value <= maxSpeed; value++) {
      final angle = startAngle + (sweepAngle * (value / maxSpeed));

      final isMajor = value % majorStep == 0;
      final isMedium = !isMajor && value % 6 == 0;
      final tickLen = isMajor ? 18.0 : (isMedium ? 12.0 : 6.0);
      final tickPaint = Paint()
        ..color = Colors.white
        ..strokeWidth = isMajor ? 3 : 1.5;

      final p1 = Offset(
        center.dx + (radius - tickLen) * cos(angle),
        center.dy + (radius - tickLen) * sin(angle),
      );
      final p2 = Offset(
        center.dx + radius * cos(angle),
        center.dy + radius * sin(angle),
      );
      canvas.drawLine(p1, p2, tickPaint);

      // Labels every 12 km/h
      if (isMajor) {
        final tp = TextPainter(
          text: TextSpan(
            text: value.toString(),
            style: const TextStyle(
              color: Colors.greenAccent,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
          textDirection: TextDirection.ltr,
        )..layout();

        final labelOffset = Offset(
          center.dx + (radius - 35) * cos(angle) - tp.width / 2,
          center.dy + (radius - 35) * sin(angle) - tp.height / 2,
        );
        tp.paint(canvas, labelOffset);
      }
    }

    // ===== Needle (light green wedge) =====
    final clamped = speed.clamp(0, maxSpeed);
    final needleAngle = startAngle + (sweepAngle * (clamped / maxSpeed));

    final path = Path();
    final base = center;
    final tip = Offset(
      center.dx + (radius - 50) * cos(needleAngle),
      center.dy + (radius - 50) * sin(needleAngle),
    );
    final left = Offset(
      center.dx + 25 * cos(needleAngle - 0.6),
      center.dy + 25 * sin(needleAngle - 0.6),
    );

    path.moveTo(base.dx, base.dy);
    path.lineTo(left.dx, left.dy);
    path.lineTo(tip.dx, tip.dy);
    path.close();

    final needlePaint = Paint()
      ..shader = const LinearGradient(
        colors: [Colors.lightGreenAccent, Colors.greenAccent],
      ).createShader(Rect.fromCircle(center: center, radius: 40));
    canvas.drawPath(path, needlePaint);

    // ===== Digital Speed Display =====
    final speedText = TextPainter(
      text: TextSpan(
        text: clamped.toStringAsFixed(1),
        style: const TextStyle(
          color: Colors.white,
          fontSize: 28,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    speedText.paint(canvas, center.translate(-speedText.width / 2, -18));

    final unitText = TextPainter(
      text: const TextSpan(
        text: "Km/h",
        style: TextStyle(
          color: Colors.white,
          fontSize: 16,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    unitText.paint(canvas, center.translate(-unitText.width / 2, 16));
  }

  @override
  bool shouldRepaint(covariant GaugePainter oldDelegate) {
    return oldDelegate.speed != speed;
  }
}
