import 'package:flutter/material.dart';

import '../utils/constants.dart';
import '../utils/sharedpreferences.dart';
import 'home_placeholder.dart';

class LoginPlaceholderPage extends StatefulWidget {
  const LoginPlaceholderPage({super.key});

  @override
  State<LoginPlaceholderPage> createState() => _LoginPlaceholderPageState();
}

class _LoginPlaceholderPageState extends State<LoginPlaceholderPage> {
  final TextEditingController _nameController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    await SharedPreferencesHelper.setBool('isLoggedIn', true);
    await SharedPreferencesHelper.setString('username', _nameController.text);

    if (!mounted) return;

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const HomePlaceholderPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: PictConstants.background,
      appBar: AppBar(
        title: const Text('Connexion'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Nom',
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _login,
                child: const Text('Continuer'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
