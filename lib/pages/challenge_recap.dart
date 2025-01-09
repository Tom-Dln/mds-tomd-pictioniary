import 'package:flutter/material.dart';

import '../utils/constants.dart';
import '../utils/dimens.dart';
import '../utils/images.dart';
import '../widgets/MyButton.dart';
import '../widgets/pict_background.dart';

class ChallengeRecapScreen extends StatelessWidget {
  const ChallengeRecapScreen({super.key});

  static final List<_RecapEntry> _entries = [
    const _RecapEntry(label: 'Une bête sur un mur', score: -1),
    const _RecapEntry(label: 'Une bête sur un mur', score: -1),
    const _RecapEntry(label: 'Une bête sur un mur', score: -1),
    const _RecapEntry(label: 'Une poule sur un mur', score: 25),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text('Une poule sur un mur'),
        leading: IconButton(
          icon: const Icon(Icons.chevron_left),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: PictGradientBackground(
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 100, 20, 32),
            children: [
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(28),
                  border: Border.all(color: Colors.white.withOpacity(0.08)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.25),
                      blurRadius: 35,
                      offset: const Offset(0, 24),
                    ),
                  ],
                ),
                clipBehavior: Clip.antiAlias,
                child: Image.asset(
                  PictImages.bird,
                  height: PictDimens.pictHeight * 4,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(height: PictDimens.pictDefaultSpace),
              const _SectionTitle('Prompt utilisé'),
              const SizedBox(height: 8),
              const Text(
                'Le piag ingrédient de base des menus KFC sur des briques empilées',
                style: TextStyle(
                  fontSize: PictDimens.pictDefaultSize,
                  color: PictConstants.PictSecondary,
                ),
              ),
              const SizedBox(height: PictDimens.pictDefaultSpace),
              const _SectionTitle('Propositions faites'),
              const SizedBox(height: 12),
              ..._entries.map(_RecapTile.new),
              const SizedBox(height: 24),
              MyButton(
                onPressed: () => Navigator.pop(context),
                text: 'Retour au challenge',
                icon: Icons.arrow_back,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontSize: PictDimens.pictDefaultSize * 1.2,
            fontWeight: FontWeight.bold,
          ),
    );
  }
}

class _RecapEntry {
  const _RecapEntry({required this.label, required this.score});

  final String label;
  final int score;
}

class _RecapTile extends StatelessWidget {
  const _RecapTile(this.entry);

  final _RecapEntry entry;

  @override
  Widget build(BuildContext context) {
    final isPositive = entry.score >= 0;
    final color = isPositive ? PictConstants.PictGreen : PictConstants.PictRed;
    final prefix = isPositive ? '+' : '';

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        gradient: LinearGradient(
          colors: isPositive
              ? [PictConstants.PictGreen.withOpacity(0.2), PictConstants.PictSurface]
              : [PictConstants.PictRed.withOpacity(0.25), PictConstants.PictSurface],
        ),
        border: Border.all(color: Colors.white.withOpacity(0.06)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              entry.label,
              style: const TextStyle(
                fontSize: PictDimens.pictDefaultSize * .9,
                color: PictConstants.PictSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Text(
            '$prefix${entry.score}',
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: PictDimens.pictDefaultSize * .9,
            ),
          ),
        ],
      ),
    );
  }
}
