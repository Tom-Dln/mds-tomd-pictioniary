import 'package:flutter/material.dart';

import '../utils/constants.dart';
import '../utils/sharedpreferences.dart';
import '../widgets/MyButton.dart';
import '../widgets/pict_background.dart';
import 'login_step_1.dart';

class HomePlaceholderScreen extends StatelessWidget {
  const HomePlaceholderScreen({super.key});

  Future<void> _logout(BuildContext context) async {
    await SharedPreferencesHelper.clearData();
    if (!context.mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (_) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.transparent,
      body: PictGradientBackground(
        child: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Text(
                    'Bienvenue dans Pictioniary',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: PictConstants.PictSecondary,
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'L\'espace d\'équipe n\'est pas encore disponible dans cette version.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.7),
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 40),
                  MyButton(
                    text: 'Se déconnecter',
                    onPressed: () => _logout(context),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
