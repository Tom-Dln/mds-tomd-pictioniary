import 'package:flutter/material.dart';

import 'challenge_recap.dart';

class ChallengeResultScreen extends StatelessWidget {
  const ChallengeResultScreen({super.key});

  static final List<_TeamResult> _redTeamStats = [
    const _TeamResult(
      title: 'Équipe rouge',
      score: '+32 / -12',
      details: 'Statistiques générales',
    ),
    const _TeamResult(
      title: 'Objectifs atteints',
      score: '+15 / -3',
      details: 'Synthèse rapide',
    ),
  ];

  static final List<_TeamResult> _blueTeamStats = [
    const _TeamResult(
      title: 'Équipe bleue',
      score: '+18 / -5',
      details: 'Statistiques générales',
    ),
    const _TeamResult(
      title: 'Objectifs atteints',
      score: '+12 / -6',
      details: 'Synthèse rapide',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Résultats du challenge'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const _SummaryCard(),
          const SizedBox(height: 16),
          ..._redTeamStats.map((stat) => _TeamResultCard(stat: stat)),
          const SizedBox(height: 8),
          ..._blueTeamStats.map((stat) => _TeamResultCard(stat: stat)),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.home),
            label: const Text('Retour à l\'accueil'),
          ),
        ],
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard();

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text(
              'Victoire de l\'équipe rouge',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            SizedBox(height: 8),
            Text('Résultat final du challenge'),
          ],
        ),
      ),
    );
  }
}

class _TeamResultCard extends StatelessWidget {
  const _TeamResultCard({required this.stat});

  final _TeamResult stat;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        title: Text(stat.title),
        subtitle: Text(stat.details),
        trailing: Text(stat.score),
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const ChallengeRecapScreen()),
          );
        },
      ),
    );
  }
}

class _TeamResult {
  const _TeamResult({
    required this.title,
    required this.score,
    required this.details,
  });

  final String title;
  final String score;
  final String details;
}
