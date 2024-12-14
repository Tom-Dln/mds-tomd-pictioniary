import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:timer_count_down/timer_count_down.dart';

import '../utils/constants.dart';
import '../utils/dimens.dart';
import '../utils/images.dart';
import '../widgets/mybutton.dart';
import '../widgets/myloader.dart';
import 'challenge_result.dart';

class ChallengeProposalScreen extends StatefulWidget {
  const ChallengeProposalScreen({super.key});

  @override
  State<ChallengeProposalScreen> createState() =>
      _ChallengeProposalScreenState();
}

class _ChallengeProposalScreenState extends State<ChallengeProposalScreen> {
  final TextEditingController _firstProposal = TextEditingController();
  final TextEditingController _secondProposal = TextEditingController();
  bool _displayQuestion = false;
  bool _showLoader = false;

  @override
  void dispose() {
    _firstProposal.dispose();
    _secondProposal.dispose();
    super.dispose();
  }

  void _toggleQuestion() {
    setState(() => _displayQuestion = !_displayQuestion);
  }

  Future<void> _simulateDrawing() async {
    setState(() => _showLoader = true);
    await Future<void>.delayed(const Duration(seconds: 3));
    if (!mounted) return;
    setState(() => _showLoader = false);
  }

  void _openProposalSheet() {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            bottom: MediaQuery.of(context).viewInsets.bottom + 20,
          ),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  PictConstants.PictSurface,
                  PictConstants.PictSurfaceVariant,
                ],
              ),
              borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Proposition de mots',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w800,
                              color: PictConstants.PictSecondary,
                            ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close, color: PictConstants.PictSecondary),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _firstProposal,
                  decoration: const InputDecoration(
                    labelText: 'Premier mot',
                    prefixIcon: Icon(Icons.text_snippet_outlined),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _secondProposal,
                  decoration: const InputDecoration(
                    labelText: 'Deuxième mot',
                    prefixIcon: Icon(Icons.text_snippet_outlined),
                  ),
                ),
                const SizedBox(height: 24),
                MyButton(
                  onPressed: () => Navigator.pop(context),
                  text: 'Enregistrer',
                  icon: Icons.save_alt,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildScoreBoard() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: const LinearGradient(
          colors: [
            PictConstants.PictSurface,
            PictConstants.PictSurfaceVariant,
          ],
        ),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: const [
          _ScoreTile(teamName: 'Équipe Néon', score: '89'),
          SizedBox(
            height: 50,
            child: VerticalDivider(color: Colors.white24, thickness: 1.2),
          ),
          _ScoreTile(teamName: 'Équipe Incandescente', score: '93'),
        ],
      ),
    );
  }

  Widget _buildCountdown() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(28),
            color: Colors.white.withOpacity(0.08),
            border: Border.all(color: Colors.white.withOpacity(0.1)),
          ),
          child: Column(
            children: [
              const Text(
                'Chrono',
                style: TextStyle(
                  color: PictConstants.PictSecondary,
                  fontSize: PictDimens.pictDefaultSize,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),
              Countdown(
                seconds: 300,
                interval: const Duration(milliseconds: 100),
                build: (_, time) => Text(
                  time.toStringAsFixed(1),
                  style: const TextStyle(
                    color: PictConstants.PictAccent,
                    fontSize: 48,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                onFinished: _simulateDrawing,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildProposals() {
    final chips = _displayQuestion
        ? const ['Une', 'Mot 1', 'sur', 'un', 'Mot 2']
        : const ['Une', 'poule', 'sur', 'un', 'mur'];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Wrap(
          spacing: 12,
          runSpacing: 12,
          alignment: _displayQuestion ? WrapAlignment.spaceBetween : WrapAlignment.center,
          children: [
            for (final chip in chips)
              _ProposalChip(
                label: chip,
                highlighted: _displayQuestion,
              ),
          ],
        ),
        if (_displayQuestion) ...[
          const SizedBox(height: 16),
          Align(
            alignment: Alignment.centerRight,
            child: IconButton(
              onPressed: _openProposalSheet,
              icon: const Icon(Icons.post_add_outlined,
                  color: PictConstants.PictAccent),
            ),
          ),
        ],
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text('Défi de devinette'),
        leading: IconButton(
          icon: const Icon(Icons.chevron_left),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: PictGradientBackground(
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 100, 20, 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildCountdown(),
                const SizedBox(height: PictDimens.pictDefaultSpace),
                _buildScoreBoard(),
                const SizedBox(height: PictDimens.pictDefaultSpace),
                if (_displayQuestion)
                  const Text(
                    'Qu’a dessiné votre équipier ?',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: PictConstants.PictSecondary,
                      fontSize: PictDimens.pictDefaultSize,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                const SizedBox(height: PictDimens.pictDefaultSpace),
                GestureDetector(
                  onTap: _toggleQuestion,
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(28),
                      border: Border.all(color: Colors.white.withOpacity(0.1)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.25),
                          blurRadius: 30,
                          offset: const Offset(0, 20),
                        ),
                      ],
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: Image.asset(
                      PictImages.bird,
                      height: 280,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                const SizedBox(height: PictDimens.pictDefaultSpace),
                _buildProposals(),
                const SizedBox(height: PictDimens.pictDefaultSpace),
                if (_displayQuestion)
                  MyButton(
                    onPressed: () {},
                    text: 'Abandonner et devenir dessinateur',
                    icon: Icons.swap_horiz,
                  ),
                const SizedBox(height: PictDimens.pictDefaultSpace),
                MyButtonWithIcon(
                  icon: Icons.logout_outlined,
                  onPressed: () {
                    Navigator.of(context).push(
                      CupertinoPageRoute(
                        builder: (context) => const ChallengeResultScreen(),
                      ),
                    );
                  },
                  text: 'Quitter la partie',
                ),
                if (_showLoader) ...[
                  const SizedBox(height: PictDimens.pictDefaultSpace),
                  const MyLoader(),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ScoreTile extends StatelessWidget {
  const _ScoreTile({required this.teamName, required this.score});

  final String teamName;
  final String score;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          teamName,
          style: const TextStyle(
            color: Colors.white,
            fontSize: PictDimens.pictDefaultSize,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          score,
          style: const TextStyle(
            color: Colors.white,
            fontSize: PictDimens.pictDefaultSize * 2,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}

class _ProposalChip extends StatelessWidget {
  const _ProposalChip({required this.label, required this.highlighted});

  final String label;
  final bool highlighted;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: highlighted
            ? const LinearGradient(
                colors: [PictConstants.PictAccent, PictConstants.PictPrimary],
              )
            : null,
        color: highlighted ? null : Colors.white.withOpacity(0.08),
        border: Border.all(
          color: highlighted
              ? Colors.transparent
              : Colors.white.withOpacity(0.15),
        ),
      ),
      child: Text(
        label.toUpperCase(),
        style: TextStyle(
          color: highlighted ? PictConstants.PictSecondary : Colors.white70,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}
