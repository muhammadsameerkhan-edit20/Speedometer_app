import 'package:flutter/material.dart';
import 'dart:math' as math;

class CustomGauge extends StatefulWidget {
  final double speed;
  final double minValue;
  final double maxValue;

  const CustomGauge({
    super.key,
    required this.speed,
    this.minValue = 0,
    this.maxValue = 240,
  });

  @override
  State<CustomGauge> createState() => _CustomGaugeState();
}

class _CustomGaugeState extends State<CustomGauge>
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
  void didUpdateWidget(CustomGauge oldWidget) {
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
    return Scaffold(
      backgroundColor: const Color(0xFF043245),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Container(
          color: Color(0xff141414),
          height: 400,
          width:double.infinity,
          child: AnimatedBuilder(
            animation: _animation,
            builder: (context, child) {
              return CustomPaint(
                size: const Size(400, 300),
                painter: GaugePainter(
                  speed: _animation.value,
                  minValue: widget.minValue,
                  maxValue: widget.maxValue,
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class GaugePainter extends CustomPainter {
  final double speed;
  final double minValue;
  final double maxValue;

  GaugePainter({
    required this.speed,
    required this.minValue,
    required this.maxValue,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height * 0.66  );
    final radius = size.width * 0.37;
    final radius2 = size.width * 0.40;
    final _drawHighlightCirclesRadius = size.width * 0.30;

    // Draw the gauge arc
    _drawGaugeArc(canvas, center, radius);

    // Draw tick marks
    _drawTickMarks(canvas, center, radius2);

    // Draw labels
    _drawLabels(canvas, center, radius2);

    // Draw highlight circles
    _drawHighlightCircles(canvas, center, _drawHighlightCirclesRadius);

    // Draw needle
    _drawNeedle(canvas, center, radius);
  }

  void _drawGaugeArc(Canvas canvas, Offset center, double radius) {
    final rect = Rect.fromCircle(center: center, radius: radius);

    // Create gradient for the arc using LinearGradient instead
    final gradient = LinearGradient(
      colors: [
        Colors.green,
        Colors.lime,
        Colors.yellow,
        Colors.orange,
        Colors.red,
      ],
      stops: [0.0, 0.35, 0.5, 0.75, 1.0],
    );

    final shader = gradient.createShader(rect);

    // Draw the arc with gradient
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = radius * 0.09
      ..strokeCap = StrokeCap.round
      ..shader = shader;

    canvas.drawArc(rect, math.pi, math.pi, false, paint);
  }


  void _drawTickMarks(Canvas canvas, Offset center, double radius) {
    final paint = Paint()
      ..color = Color(0xff68DAE4)
      ..style = PaintingStyle.stroke;

    const int totalTicks = 90; // (10 minor + 1 major) * 11 segments
    final double angleStep = math.pi / (totalTicks - 1); // 180 degrees = pi radians

    for (int i = 0; i < totalTicks; i++) {
      final angle = math.pi + (i * angleStep); // start at 180°

      bool isMajor = i % 11 == 0; // Every 11th tick is major

      final double startOffset = isMajor ? radius - 5 : radius - 2;
      final double endOffset = isMajor ? radius + 22 : radius + 3;

      final startPoint = Offset(
        center.dx + startOffset * math.cos(angle),
        center.dy + startOffset * math.sin(angle),
      );

      final endPoint = Offset(
        center.dx + endOffset * math.cos(angle),
        center.dy + endOffset * math.sin(angle),
      );

      paint.strokeWidth = isMajor ? 2.5 : 1;
      canvas.drawLine(startPoint, endPoint, paint);
    }
  }

  void _drawLabels(Canvas canvas, Offset center, double radius) {
    final textStyle = TextStyle(
      color: const Color(0xff68DAE4),
      fontSize:10,
      fontWeight: FontWeight.w600,
    );

    for (int i = 0; i <= 8; i++) {
      final angle = math.pi + (i * math.pi / 8);
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
        center.dx + (radius + 30) * math.cos(angle) - textPainter.width / 2,
        center.dy + (radius + 30) * math.sin(angle) - textPainter.height / 2,
      );
      textPainter.paint(canvas, labelOffset);
    }
  }

  void _drawHighlightCircles(Canvas canvas, Offset center, double radius) {
    final positions = [
      (math.pi, Colors.green),
      (math.pi + 1.6, Colors.yellow),
      (0, Colors.red),
    ];

    for (final (angle, color) in positions) {
      final circleCenter = Offset(
        center.dx + (radius + 20) * math.cos(angle),
        center.dy + (radius + 20) * math.sin(angle),
      );

      // Outer white circle
      final outerPaint = Paint()
        ..color = Colors.white
        ..style = PaintingStyle.fill;
      canvas.drawCircle(circleCenter, 8, outerPaint);

      // Inner colored circle
      final innerPaint = Paint()
        ..color = color
        ..style = PaintingStyle.fill;
      canvas.drawCircle(circleCenter, 7, innerPaint);
    }
  }

  void _drawNeedle(Canvas canvas, Offset center, double radius) {
    final speedAngle = math.pi + (speed / maxValue) * math.pi;

    // Draw needle tail (base)
    // final tailPaint = Paint()
    //   ..color = const Color(0xFF7FDBFF)
    //   ..style = PaintingStyle.fill;
    //
    // final tailPath = Path();
    // final tailLength = radius * 0.3;
    // final tailWidth = 8;
    //
    // final tailStart = Offset(
    //   center.dx + tailLength * math.cos(speedAngle),
    //   center.dy - tailLength * math.sin(speedAngle),
    // );
    // final tailEnd = Offset(
    //   center.dx - (tailLength + 20) * math.cos(speedAngle),
    //   center.dy - (tailLength + 20) * math.sin(speedAngle),
    // );
    //
    // tailPath.moveTo(
    //   tailStart.dx - tailWidth * math.sin(speedAngle),
    //   tailStart.dy + tailWidth * math.cos(speedAngle),
    // );
    // tailPath.lineTo(
    //   tailEnd.dx - tailWidth * math.sin(speedAngle),
    //   tailEnd.dy + tailWidth * math.cos(speedAngle),
    // );
    // tailPath.lineTo(
    //   tailEnd.dx + tailWidth * math.sin(speedAngle),
    //   tailEnd.dy - tailWidth * math.cos(speedAngle),
    // );
    // tailPath.lineTo(
    //   tailStart.dx + tailWidth * math.sin(speedAngle),
    //   tailStart.dy - tailWidth * math.cos(speedAngle),
    // );
    // tailPath.close();
    // canvas.drawPath(tailPath, tailPaint);

    // Draw needle
    final needlePaint = Paint()
      ..shader = const LinearGradient(
        colors: [
          Color(0xFFD8FCFF), // Light blue
          Color(0xFF68DAE4), // Deeper blue
        ],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(Rect.fromCircle(
        center: center,
        radius: radius,
      ))
      ..style = PaintingStyle.fill;

    final needlePath = Path();
    final needleLength = radius * 0.79;
    final needleWidth = 8;

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
      needleTip.dx - needleWidth * math.sin(speedAngle),
      needleTip.dy + needleWidth * math.cos(speedAngle),
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
    canvas.drawCircle(center, 17, hubPaint);

    final hubBorderPaint = Paint()
      ..color = const Color(0xFF7FDBFF)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5;
    canvas.drawCircle(center, 12, hubBorderPaint);
  }


  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}



