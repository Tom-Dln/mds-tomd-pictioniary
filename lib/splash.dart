import 'package:flutter/material.dart';

import 'pages/home_placeholder.dart';
import 'pages/login_placeholder.dart';
import 'utils/constants.dart';
import 'utils/sharedpreferences.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    final isLoggedIn = await SharedPreferencesHelper.getBool('isLoggedIn') ?? false;

    if (!mounted) return;

    if (isLoggedIn) {
      _open(const HomePlaceholderPage());
    } else {
      _open(const LoginPlaceholderPage());
    }
  }

  void _open(Widget page) {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => page),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: PictConstants.background,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: const [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text(
              'Chargement... ',
              style: TextStyle(
                color: PictConstants.textSecondary,
                fontSize: PictConstants.fontSizeSmall,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
