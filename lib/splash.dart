// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';

import 'pages/home_placeholder.dart';
import 'pages/login_step_1.dart';
import 'utils/constants.dart';
import 'utils/images.dart';
import 'utils/sharedpreferences.dart';
import 'widgets/myloader.dart';
import 'widgets/pict_background.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _bootstrapSession();
  }

  Future<void> _bootstrapSession() async {
    final userId = await SharedPreferencesHelper.getInt('id');
    await Future<void>.delayed(const Duration(seconds: 2));

    if (!mounted) return;

    if (userId != null) {
      _openScreen(const HomePlaceholderScreen());
      return;
    }

    _openScreen(const LoginScreen());
  }

  void _openScreen(Widget page) {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => page),
      (_) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PictGradientBackground(
        child: SafeArea(
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: const [
                _AnimatedLogo(),
                SizedBox(height: 48),
                MyLoader(),
                SizedBox(height: 16),
                Text(
                  'Préparation de votre session créative...',
                  style: TextStyle(
                    color: PictConstants.PictSecondary,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _AnimatedLogo extends StatefulWidget {
  const _AnimatedLogo();

  @override
  State<_AnimatedLogo> createState() => _AnimatedLogoState();
}

class _AnimatedLogoState extends State<_AnimatedLogo>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _scaleAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutBack,
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scaleAnimation,
      child: Container(
        padding: const EdgeInsets.all(28),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(36),
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              PictConstants.PictSurface,
              PictConstants.PictSurfaceVariant,
            ],
          ),
          boxShadow: [
            BoxShadow(
              color: PictConstants.PictPrimary.withOpacity(0.35),
              blurRadius: 45,
              offset: const Offset(0, 24),
            ),
          ],
          border: Border.all(
            color: PictConstants.PictPrimary.withOpacity(0.35),
            width: 1.2,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              height: 120,
              width: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(
                  colors: [PictConstants.PictPrimary, PictConstants.PictAccent],
                ),
                boxShadow: [
                  BoxShadow(
                    color: PictConstants.PictAccent.withOpacity(0.4),
                    blurRadius: 30,
                    offset: const Offset(0, 12),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Image.asset(PictImages.appLogo),
              ),
            ),
            const SizedBox(height: 18),
            const Text(
              'mds-tomd-pictioniary',
              style: TextStyle(
                color: PictConstants.PictSecondary,
                fontSize: 20,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.4,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              PictConstants.appName,
              style: TextStyle(
                color: Colors.white.withOpacity(0.65),
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
