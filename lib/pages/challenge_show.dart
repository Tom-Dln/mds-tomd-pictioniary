import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';

import '../models/challenge.dart';
import '../utils/actions.dart';
import '../utils/api.dart';
import '../utils/constants.dart';
import '../utils/sharedpreferences.dart';
import '../widgets/MyButton.dart';
import '../widgets/mychallengecard.dart';
import '../widgets/myloader.dart';
import '../widgets/pict_background.dart';

class ChallengeDrawScreen extends StatefulWidget {
  const ChallengeDrawScreen({super.key});

  @override
  State<ChallengeDrawScreen> createState() => _ChallengeDrawScreenState();
}

class _ChallengeDrawScreenState extends State<ChallengeDrawScreen> {
  final List<Challenge> _challenges = [];
  final TextEditingController _promptController = TextEditingController();
  int _currentIndex = 0;
  bool _isLoading = true;
  int _remainingRegenerations = 2;
  Timer? _statusTimer;
  String _sessionId = '';

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  @override
  void dispose() {
    _statusTimer?.cancel();
    _promptController.dispose();
    super.dispose();
  }

  Future<void> _initialize() async {
    _sessionId = await SharedPreferencesHelper.getString('gameSessionId') ?? '';
    if (_sessionId.isEmpty) {
      if (mounted) {
        showToastError(context, 'Session introuvable.');
      }
      setState(() => _isLoading = false);
      return;
    }

    await _loadChallenges();
    _startStatusPolling();
  }

  void _startStatusPolling() {
    _statusTimer = Timer.periodic(
      const Duration(seconds: 5),
      (_) => _checkGameStatus(),
    );
  }

  Future<void> _checkGameStatus() async {
    try {
      final status =
          await PictApi.get('${PictApi.GAME_SESSIONS}/$_sessionId/status');
      if (status['status'] == 'guessing') {
        if (mounted) {
          showToast(context, 'Phase de devinette lancée.');
          Navigator.pop(context);
        }
      }
    } catch (error) {
      debugPrint('Erreur de vérification du statut: $error');
    }
  }

  Future<void> _loadChallenges() async {
    setState(() => _isLoading = true);
    try {
      final response = await PictApi.get(
        '${PictApi.GAME_SESSIONS}/$_sessionId/myChallenges',
      );
      final fetched = <Challenge>[];
      for (final item in response) {
        fetched.add(Challenge.fromJson(item));
      }
      setState(() {
        _challenges
          ..clear()
          ..addAll(fetched);
        _currentIndex = 0;
        _isLoading = false;
      });
    } catch (error) {
      if (mounted) {
        showToastError(context, 'Impossible de récupérer les données.');
      }
      setState(() => _isLoading = false);
    }
  }

  Future<void> _submitPrompt() async {
    if (_promptController.text.trim().isEmpty) {
      showToast(context, 'Veuillez entrer un texte.');
      return;
    }

    setState(() => _isLoading = true);
    try {
      final challenge = _challenges[_currentIndex];
      final response = await PictApi.post(
        '${PictApi.GAME_SESSIONS}/$_sessionId/challenges/${challenge.id}/draw',
        {'prompt': _promptController.text},
      );
      setState(() {
        _challenges[_currentIndex] = Challenge.fromJson(response);
        _promptController.clear();
        _isLoading = false;
      });
      showToast(context, 'Image générée.');
    } catch (error) {
      showToastError(context, 'Erreur lors de la génération.');
      setState(() => _isLoading = false);
    }
  }

  Future<void> _regenerateImage() async {
    if (_remainingRegenerations <= 0) {
      showToast(context, 'Aucune régénération restante.');
      return;
    }

    final challenge = _challenges[_currentIndex];
    if (challenge.prompt.isEmpty) {
      showToast(context, 'Aucun prompt disponible.');
      return;
    }

    setState(() => _isLoading = true);
    try {
      final response = await PictApi.post(
        '${PictApi.GAME_SESSIONS}/$_sessionId/challenges/${challenge.id}/draw',
        {'prompt': challenge.prompt},
      );
      setState(() {
        _challenges[_currentIndex] = Challenge.fromJson(response);
        _remainingRegenerations--;
        _isLoading = false;
      });
      showToast(context, 'Image régénérée.');
    } catch (error) {
      showToastError(context, 'Erreur lors de la régénération.');
      setState(() => _isLoading = false);
    }
  }

  void _nextChallenge() {
    if (_currentIndex < _challenges.length - 1) {
      setState(() => _currentIndex++);
    } else {
      showToast(context, 'Tous les challenges sont terminés.');
    }
  }

  void _previousChallenge() {
    if (_currentIndex > 0) {
      setState(() => _currentIndex--);
    }
  }

  Future<void> _confirmExit() async {
    final shouldLeave = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Quitter le challenge'),
        content:
            const Text('Êtes-vous sûr de vouloir quitter le challenge ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Quitter'),
          ),
        ],
      ),
    );

    if (shouldLeave == true && mounted) {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: Text(
          'Challenge ${_challenges.isEmpty ? 0 : _currentIndex + 1}/${_challenges.length}',
        ),
        leading: IconButton(
          onPressed: _confirmExit,
          icon: const Icon(Icons.chevron_left),
        ),
      ),
      body: PictGradientBackground(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 100, 20, 20),
            child: _isLoading
                ? const Center(child: MyLoader())
                : _challenges.isEmpty
                    ? const _EmptyState()
                    : Column(
                        children: [
                          _ChallengeProgress(
                            current: _currentIndex,
                            total: _challenges.length,
                            onNext: _nextChallenge,
                            onPrevious: _previousChallenge,
                          ),
                          const SizedBox(height: 18),
                          buildChallengeCard(
                            _currentIndex + 1,
                            '${_challenges[_currentIndex].firstWord} ${_challenges[_currentIndex].secondWord} ${_challenges[_currentIndex].thirdWord} ${_challenges[_currentIndex].fourthWord} ${_challenges[_currentIndex].fifthWord}',
                            List<String>.from(
                              jsonDecode(_challenges[_currentIndex].forbiddenWords),
                            ),
                          ),
                          const SizedBox(height: 24),
                          Expanded(
                            child: _ChallengePreview(
                              imagePath: _challenges[_currentIndex].imagePath,
                              onRegenerate: _regenerateImage,
                              onValidate: _nextChallenge,
                              canRegenerate: _remainingRegenerations > 0 &&
                                  _challenges[_currentIndex].prompt.isNotEmpty,
                              canValidate:
                                  _challenges[_currentIndex].imagePath.isNotEmpty,
                              remaining: _remainingRegenerations,
                            ),
                          ),
                          const SizedBox(height: 20),
                          _PromptComposer(
                            controller: _promptController,
                            onSubmit: _submitPrompt,
                          ),
                        ],
                      ),
          ),
        ),
      ),
    );
  }
}

class _ChallengeProgress extends StatelessWidget {
  const _ChallengeProgress({
    required this.current,
    required this.total,
    required this.onNext,
    required this.onPrevious,
  });

  final int current;
  final int total;
  final VoidCallback onNext;
  final VoidCallback onPrevious;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _ProgressButton(
            icon: Icons.chevron_left,
            enabled: current > 0,
            onTap: onPrevious,
          ),
          Expanded(
            child: LinearProgressIndicator(
              value: total == 0 ? 0 : (current + 1) / total,
              minHeight: 8,
              backgroundColor: Colors.white.withOpacity(0.12),
              valueColor: const AlwaysStoppedAnimation<Color>(
                PictConstants.PictAccent,
              ),
            ),
          ),
          _ProgressButton(
            icon: Icons.chevron_right,
            enabled: current < total - 1,
            onTap: onNext,
          ),
        ],
      ),
    );
  }
}

class _ProgressButton extends StatelessWidget {
  const _ProgressButton({
    required this.icon,
    required this.enabled,
    required this.onTap,
  });

  final IconData icon;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: GestureDetector(
        onTap: enabled ? onTap : null,
        child: AnimatedOpacity(
          duration: const Duration(milliseconds: 200),
          opacity: enabled ? 1 : 0.3,
          child: Container(
            height: 42,
            width: 42,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withOpacity(0.08),
              border: Border.all(
                color: enabled
                    ? PictConstants.PictAccent
                    : Colors.white24,
              ),
            ),
            child: Icon(icon, color: Colors.white),
          ),
        ),
      ),
    );
  }
}

class _ChallengePreview extends StatelessWidget {
  const _ChallengePreview({
    required this.imagePath,
    required this.onRegenerate,
    required this.onValidate,
    required this.canRegenerate,
    required this.canValidate,
    required this.remaining,
  });

  final String imagePath;
  final VoidCallback onRegenerate;
  final VoidCallback onValidate;
  final bool canRegenerate;
  final bool canValidate;
  final int remaining;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(32),
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                PictConstants.PictSurface,
                PictConstants.PictSurfaceVariant,
              ],
            ),
            border: Border.all(
              color: Colors.white.withOpacity(0.08),
            ),
          ),
          clipBehavior: Clip.antiAlias,
          child: imagePath.isNotEmpty
              ? Image.network(
                  imagePath,
                  fit: BoxFit.cover,
                  loadingBuilder: (context, child, progress) {
                    if (progress == null) return child;
                    return const Center(
                      child: CircularProgressIndicator(
                        color: PictConstants.PictSecondary,
                      ),
                    );
                  },
                )
              : const Center(
                  child: Text(
                    "Pas encore d'image générée",
                    style: TextStyle(
                      color: PictConstants.PictGrey,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
        ),
        Positioned(
          bottom: 16,
          left: 16,
          right: 16,
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: canRegenerate ? onRegenerate : null,
                  icon: const Icon(Icons.refresh, color: PictConstants.PictAccent),
                  label: Text(
                    'Régénérer (-50pts)\n$remaining restants',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: canRegenerate
                          ? PictConstants.PictSecondary
                          : Colors.white38,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(
                      color: canRegenerate
                          ? PictConstants.PictAccent
                          : Colors.white24,
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: MyButton(
                  onPressed: canValidate ? onValidate : null,
                  text: 'Valider et\nsuivant',
                  icon: Icons.check_circle,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _PromptComposer extends StatelessWidget {
  const _PromptComposer({
    required this.controller,
    required this.onSubmit,
  });

  final TextEditingController controller;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        18,
        18,
        18,
        MediaQuery.of(context).padding.bottom + 18,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        color: PictConstants.PictSurface.withOpacity(0.9),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              style: const TextStyle(color: PictConstants.PictSecondary),
              decoration: const InputDecoration(
                hintText: 'Décris le dessin à générer',
                hintStyle: TextStyle(color: PictConstants.PictGrey),
                border: InputBorder.none,
              ),
            ),
          ),
          const SizedBox(width: 12),
          SizedBox(
            height: 56,
            width: 160,
            child: MyButton(
              onPressed: onSubmit,
              text: 'Générer',
              icon: Icons.bolt,
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(32),
          color: PictConstants.PictSurface.withOpacity(0.85),
          border: Border.all(color: Colors.white.withOpacity(0.08)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: const [
            Icon(Icons.brush_outlined, size: 72, color: PictConstants.PictAccent),
            SizedBox(height: 16),
            Text(
              'Aucun challenge disponible',
              style: TextStyle(
                color: PictConstants.PictSecondary,
                fontWeight: FontWeight.w700,
                fontSize: 20,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 12),
            Text(
              'Patientez pendant que votre équipe prépare les défis.',
              style: TextStyle(color: PictConstants.PictGrey),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
