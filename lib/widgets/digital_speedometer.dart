import 'package:flutter/material.dart';
import 'dart:math' as math;

class DigitalSpeedometer extends StatefulWidget {
  final double speed;
  final double totalDistance;

  const DigitalSpeedometer({
    super.key,


    required this.speed,
    this.totalDistance = 0,
  });

  @override

  State<DigitalSpeedometer> createState() => _DigitalSpeedometerState();
}

class _DigitalSpeedometerState extends State<DigitalSpeedometer>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _animation = Tween<double>(
      begin: 0,
      end: widget.speed,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));
    _animationController.forward();
  }

  @override
  void didUpdateWidget(DigitalSpeedometer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.speed != widget.speed) {
      _animation = Tween<double>(
        begin: oldWidget.speed,
        end: widget.speed,
      ).animate(CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOutCubic,
      ));
      _animationController.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return CustomPaint(
          size: const Size(280, 280),
          painter: DigitalSpeedometerPainter(
            speed: _animation.value,
            totalDistance: widget.totalDistance,
          ),
        );
      },
    );
  }
}

class DigitalSpeedometerPainter extends CustomPainter {
  final double speed;
  final double totalDistance;

  DigitalSpeedometerPainter({
    required this.speed,
    required this.totalDistance,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Move the gauge a bit more upward
    final center = Offset(size.width / 2, size.height * 0.46);
    final radius = size.width * 0.35;

    // Draw the gauge arc
    _drawGaugeArc(canvas, center, radius);
    
    // Draw tick marks
    _drawTickMarks(canvas, center, radius);
    
    // Draw labels
    _drawLabels(canvas, center, radius);
    
    // Removed highlight circles around digits for a cleaner look
    
    // Draw needle
    _drawNeedle(canvas, center, radius);
    
    // Draw digital display (adjusted center '0' closer to needle hub)
    _drawDigitalDisplay(canvas, center);
    
    // Odometer removed per design request
    
    // Removed extra decorative elements
  }

  void _drawGaugeArc(Canvas canvas, Offset center, double radius) {
    final rect = Rect.fromCircle(center: center, radius: radius);
    
    // Create gradient for the arc
    final gradient = LinearGradient(
      colors: [
        Colors.green,
        Colors.lime,
        Colors.yellow,
        Colors.orange,
        Colors.red,
      ],
      stops: [0.0, 0.25, 0.5, 0.75, 1.0],
    );

    final shader = gradient.createShader(rect);
    
    // Draw the arc with gradient
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = radius * 0.12
      ..strokeCap = StrokeCap.round
      ..shader = shader;

    canvas.drawArc(rect, math.pi, math.pi, false, paint);
  }

  void _drawTickMarks(Canvas canvas, Offset center, double radius) {
    final paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    for (int i = 0; i <= 8; i++) {
      final angle = math.pi - (i * math.pi / 8);
      final startPoint = Offset(
        center.dx + (radius - 15) * math.cos(angle),
        center.dy + (radius - 15) * math.sin(angle),
      );
      final endPoint = Offset(
        center.dx + (radius + 8) * math.cos(angle),
        center.dy + (radius + 8) * math.sin(angle),
      );
      canvas.drawLine(startPoint, endPoint, paint);

      // Draw minor ticks
      if (i < 8) {
        for (int j = 1; j <= 2; j++) {
          final minorAngle = angle - (j * math.pi / 24);
          final minorStartPoint = Offset(
            center.dx + (radius - 8) * math.cos(minorAngle),
            center.dy + (radius - 8) * math.sin(minorAngle),
          );
          final minorEndPoint = Offset(
            center.dx + (radius + 4) * math.cos(minorAngle),
            center.dy + (radius + 4) * math.sin(minorAngle),
          );
          canvas.drawLine(minorStartPoint, minorEndPoint, paint);
        }
      }
    }
  }

  void _drawLabels(Canvas canvas, Offset center, double radius) {
    final textStyle = TextStyle(
      color: const Color(0xFF7FDBFF),
      fontSize: 14,
      fontWeight: FontWeight.w600,
    );

    for (int i = 0; i <= 8; i++) {
      final angle = math.pi - (i * math.pi / 8);
      final value = (i * 30).toDouble();
      final textSpan = TextSpan(
        text: value.toInt().toString(),
        style: textStyle,
      );
      final textPainter = TextPainter(
        text: textSpan,
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();

      final labelOffset = Offset(
        center.dx + (radius + 20) * math.cos(angle) - textPainter.width / 2,
        center.dy + (radius + 20) * math.sin(angle) - textPainter.height / 2,
      );
      textPainter.paint(canvas, labelOffset);
    }
  }

  void _drawHighlightCircles(Canvas canvas, Offset center, double radius) {}

  void _drawNeedle(Canvas canvas, Offset center, double radius) {
    final speedAngle = math.pi - (speed / 240) * math.pi;
    
    // Draw needle
    final needlePaint = Paint()
      ..color = const Color(0xFF7FDBFF)
      ..style = PaintingStyle.fill;
    
    final needlePath = Path();
    final needleLength = radius * 0.7;
    final needleWidth = 6;
    
    final needleTip = Offset(
      center.dx + needleLength * math.cos(speedAngle),
      center.dy + needleLength * math.sin(speedAngle),
    );
    
    needlePath.moveTo(
      center.dx - needleWidth * math.sin(speedAngle),
      center.dy + needleWidth * math.cos(speedAngle),
    );
    needlePath.lineTo(
      needleTip.dx - needleWidth * math.sin(speedAngle),
      needleTip.dy + needleWidth * math.cos(speedAngle),
    );
    needlePath.lineTo(
      needleTip.dx + needleWidth * math.sin(speedAngle),
      needleTip.dy - needleWidth * math.cos(speedAngle),
    );
    needlePath.lineTo(
      center.dx + needleWidth * math.sin(speedAngle),
      center.dy - needleWidth * math.cos(speedAngle),
    );
    needlePath.close();
    canvas.drawPath(needlePath, needlePaint);

    // Draw central hub
    final hubPaint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, 12, hubPaint);
    
    final hubBorderPaint = Paint()
      ..color = const Color(0xFF7FDBFF)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    canvas.drawCircle(center, 12, hubBorderPaint);
  }

  void _drawDigitalDisplay(Canvas canvas, Offset center) {
    // Draw digital speed display
    final speedTextStyle = TextStyle(
      color: const Color(0xFF7FDBFF),
      fontSize: 24,
      fontWeight: FontWeight.bold,
    );

    final speedTextSpan = TextSpan(
      text: speed.toInt().toString(),
      style: speedTextStyle,
    );
    final speedTextPainter = TextPainter(
      text: speedTextSpan,
      textDirection: TextDirection.ltr,
    );
    speedTextPainter.layout();

    // Place numeric readout exactly at the circle center
    final speedOffset = Offset(
      center.dx - speedTextPainter.width / 2,
      center.dy - speedTextPainter.height / 2,
    );
    speedTextPainter.paint(canvas, speedOffset);

    // Draw KM/H label
    final unitTextStyle = TextStyle(
      color: const Color(0xFF7FDBFF),
      fontSize: 12,
      fontWeight: FontWeight.w500,
    );

    final unitTextSpan = TextSpan(
      text: "KM/H",
      style: unitTextStyle,
    );
    final unitTextPainter = TextPainter(
      text: unitTextSpan,
      textDirection: TextDirection.ltr,
    );
    unitTextPainter.layout();

    // Position KM/H label just below the centered number
    final unitOffset = Offset(
      center.dx - unitTextPainter.width / 2,
      center.dy + speedTextPainter.height / 2 + 4,
    );
    unitTextPainter.paint(canvas, unitOffset);
  }

  void _drawOdometer(Canvas canvas, Size size) {}

  void _drawAdditionalElements(Canvas canvas, Size size) {}

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
} 