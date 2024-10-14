import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../utils/constants.dart';

class MyLoader extends StatefulWidget {
  const MyLoader({super.key});

  @override
  State<MyLoader> createState() => _MyLoaderState();
}

class _MyLoaderState extends State<MyLoader>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 64,
      width: 64,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          final angle = _controller.value * 2 * math.pi;
          return CustomPaint(
            painter: _LoaderPainter(angle: angle),
          );
        },
      ),
    );
  }
}

class _LoaderPainter extends CustomPainter {
  const _LoaderPainter({required this.angle});

  final double angle;

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = size.width / 2;
    final backgroundPaint = Paint()
      ..color = PictConstants.PictSurface.withOpacity(0.6)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6;
    final gradientPaint = Paint()
      ..shader = SweepGradient(
        colors: const [
          PictConstants.PictAccent,
          PictConstants.PictPrimary,
          PictConstants.PictAccent,
        ],
        startAngle: 0,
        endAngle: 2 * math.pi,
        transform: GradientRotation(angle),
      ).createShader(Rect.fromCircle(center: center, radius: radius))
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 6.5;

    canvas.drawCircle(center, radius - 4, backgroundPaint);
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius - 4),
      -math.pi / 2,
      1.8 * math.pi,
      false,
      gradientPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _LoaderPainter oldDelegate) =>
      oldDelegate.angle != angle;
}
