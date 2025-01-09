import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../utils/constants.dart';
import '../utils/dimens.dart';
import '../utils/images.dart';
import 'challenge_recap.dart';

class ChallengeResultScreen extends StatelessWidget {
  const ChallengeResultScreen({super.key});

  static final List<_TeamResult> _redTeamStats = [
    const _TeamResult(
      title: 'Évolution du vol des rapaces',
      imagePath: PictImages.bird,
      positive: 32,
      negative: 12,
      tags: ['Aigle', 'Rapace', 'Prédateur'],
    ),
    const _TeamResult(
      title: 'Statistiques de migration des oiseaux',
      imagePath: PictImages.bird,
      positive: 15,
      negative: 3,
      tags: ['Migration', 'Oiseau'],
    ),
    const _TeamResult(
      title: 'Tendances de nidification',
      imagePath: PictImages.bird,
      positive: 8,
      negative: 2,
      tags: ['Nid', 'Oiseau'],
    ),
  ];

  static final List<_TeamResult> _blueTeamStats = [
    const _TeamResult(
      title: 'Augmentation de la population de canards',
      imagePath: PictImages.bird,
      positive: 18,
      negative: 5,
      tags: ['Canard', 'Aquatique'],
    ),
    const _TeamResult(
      title: 'Réduction des habitats pour les oiseaux',
      imagePath: PictImages.bird,
      positive: 12,
      negative: 15,
      tags: ['Habitat', 'Espèces'],
    ),
    const _TeamResult(
      title: 'Observation des comportements de chasse',
      imagePath: PictImages.bird,
      positive: 20,
      negative: 6,
      tags: ['Faucon', 'Chasse', 'Rapace'],
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text('Résultats | Challenge #1'),
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
              _VictoryCard(
                title: "Victoire de l’équipe ROUGE",
                subtitle: 'Résumé de la partie des rouges',
              ),
              ..._redTeamStats.map((stat) => _TeamResultCard(stat: stat)).toList(),
              const SizedBox(height: PictDimens.pictDefaultSpace),
              const Text(
                'Résumé de la partie des bleus',
                style: TextStyle(
                  color: PictConstants.PictSecondary,
                  fontSize: PictDimens.pictDefaultSize,
                  fontWeight: FontWeight.w600,
                ),
              ),
              ..._blueTeamStats.map((stat) => _TeamResultCard(stat: stat)).toList(),
              const SizedBox(height: 24),
              MyButton(
                onPressed: () => Navigator.pop(context),
                text: 'Retour à l’accueil',
                icon: Icons.home,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _VictoryCard extends StatelessWidget {
  const _VictoryCard({required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(PictDimens.pictPadding * 1.2),
      margin: const EdgeInsets.only(bottom: PictDimens.pictDefaultSpace),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(PictDimens.pictRadius * 1.5),
        gradient: const LinearGradient(
          colors: [
            PictConstants.PictSurface,
            PictConstants.PictSurfaceVariant,
          ],
        ),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.25),
            blurRadius: 40,
            offset: const Offset(0, 24),
          ),
        ],
      ),
      child: Column(
        children: [
          Image.asset(
            PictImages.stars,
            height: 120,
            width: 120,
            fit: BoxFit.contain,
          ),
          const SizedBox(height: PictDimens.pictDefaultSpace),
          Text(
            title,
            style: const TextStyle(
              color: PictConstants.PictSecondary,
              fontSize: PictDimens.pictDefaultSize * 1.1,
              fontWeight: FontWeight.w800,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: PictDimens.pictDefaultSpace * .8),
          Text(
            subtitle,
            style: TextStyle(
              color: Colors.white.withOpacity(0.7),
              fontSize: PictDimens.pictDefaultSize,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _TeamResultCard extends StatelessWidget {
  const _TeamResultCard({required this.stat});

  final _TeamResult stat;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(PictDimens.pictRadius * 1.4),
      onTap: () {
        Navigator.of(context).push(
          CupertinoPageRoute(
            builder: (context) => const ChallengeRecapScreen(),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(PictDimens.pictRadius * 1.4),
          gradient: const LinearGradient(
            colors: [
              PictConstants.PictSurface,
              PictConstants.PictSurfaceVariant,
            ],
          ),
          border: Border.all(color: Colors.white.withOpacity(0.06)),
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(PictDimens.pictRadius * 1.4),
              child: Image.asset(
                stat.imagePath,
                width: PictDimens.pictWidth,
                height: PictDimens.pictHeight,
                fit: BoxFit.cover,
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(PictDimens.pictPadding),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      stat.title,
                      style: const TextStyle(
                        color: PictConstants.PictSecondary,
                        fontSize: PictDimens.pictDefaultSize * .85,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Text(
                          '+${stat.positive}',
                          style: const TextStyle(
                            color: PictConstants.PictGreen,
                            fontSize: PictDimens.pictDefaultSize * .9,
                          ),
                        ),
                        const Text(
                          ' / ',
                          style: TextStyle(
                            color: Colors.white54,
                            fontSize: PictDimens.pictDefaultSize * .9,
                          ),
                        ),
                        Text(
                          '-${stat.negative}',
                          style: const TextStyle(
                            color: PictConstants.PictRed,
                            fontSize: PictDimens.pictDefaultSize * .9,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 6,
                      children: stat.tags
                          .map(
                            (tag) => Chip(
                              label: Text(
                                tag,
                                style: const TextStyle(
                                  fontSize: PictDimens.pictDefaultSize * .6,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              backgroundColor: Colors.white.withOpacity(0.08),
                              labelStyle: const TextStyle(
                                color: PictConstants.PictSecondary,
                              ),
                            ),
                          )
                          .toList(),
                    ),
                  ],
                ),
              ),
            ),
            const Padding(
              padding: EdgeInsets.only(right: 12),
              child: Icon(Icons.arrow_forward_ios_rounded, size: 24, color: Colors.white54),
            ),
          ],
        ),
      ),
    );
  }
}

class _TeamResult {
  const _TeamResult({
    required this.title,
    required this.imagePath,
    required this.positive,
    required this.negative,
    required this.tags,
  });

  final String title;
  final String imagePath;
  final int positive;
  final int negative;
  final List<String> tags;
}
