import 'package:flutter/material.dart';

import '../utils/constants.dart';
import '../utils/sharedpreferences.dart';
import 'login_placeholder.dart';

class HomePlaceholderPage extends StatelessWidget {
  const HomePlaceholderPage({super.key});

  Future<void> _logout(BuildContext context) async {
    await SharedPreferencesHelper.setBool('isLoggedIn', false);

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const LoginPlaceholderPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: PictConstants.background,
      appBar: AppBar(
        title: const Text('Accueil'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Bienvenue dans Piction.ia.ry !',
                style: TextStyle(
                  fontSize: PictConstants.fontSizeLarge,
                  color: PictConstants.textPrimary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => _logout(context),
                child: const Text('Se déconnecter'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
