import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../utils/constants.dart';

class PictGradientBackground extends StatelessWidget {
  const PictGradientBackground({
    super.key,
    required this.child,
    this.showAnimatedOrbs = true,
  });

  final Widget child;
  final bool showAnimatedOrbs;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            PictConstants.PictBlack,
            Color(0xFF1B1B3A),
            PictConstants.PictSurfaceVariant,
          ],
        ),
      ),
      child: Stack(
        children: [
          if (showAnimatedOrbs)
            const _Aurora(),
          child,
        ],
      ),
    );
  }
}

class _Aurora extends StatefulWidget {
  const _Aurora();

  @override
  State<_Aurora> createState() => _AuroraState();
}

class _AuroraState extends State<_Aurora>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 18),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      ignoring: true,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          return Stack(
            children: [
              _orb(
                offset: Offset(
                  200 * _noise(_controller.value, seed: 0),
                  120 * _noise(_controller.value, seed: 1),
                ),
                color: PictConstants.PictPrimary.withOpacity(0.35),
                size: 320,
              ),
              _orb(
                offset: Offset(
                  -150 * _noise(_controller.value, seed: 2),
                  220 * _noise(_controller.value, seed: 3),
                ),
                color: PictConstants.PictAccent.withOpacity(0.25),
                size: 260,
              ),
              _orb(
                offset: Offset(
                  240 * _noise(_controller.value, seed: 4),
                  -180 * _noise(_controller.value, seed: 5),
                ),
                color: PictConstants.PictOrange.withOpacity(0.2),
                size: 280,
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _orb({required Offset offset, required Color color, required double size}) {
    return Align(
      alignment: Alignment.center,
      child: Transform.translate(
        offset: offset,
        child: Container(
          height: size,
          width: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(
              colors: [color, color.withOpacity(0)],
            ),
          ),
        ),
      ),
    );
  }

  double _noise(double t, {required int seed}) {
    return (math.sin((t + seed) * 2 * math.pi) + 1) / 2;
  }
}
