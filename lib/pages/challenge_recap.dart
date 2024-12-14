import 'package:flutter/material.dart';

class ChallengeRecapScreen extends StatelessWidget {
  const ChallengeRecapScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Récapitulatif'),
      ),
      body: const Center(
        child: Text('Le récapitulatif sera disponible plus tard.'),
      ),
    );
  }
}
