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
import 'challenge_show.dart';
import 'login_step_1.dart';

class ChallengeInputScreen extends StatefulWidget {
  const ChallengeInputScreen({super.key});

  @override
  State<ChallengeInputScreen> createState() => _ChallengeInputScreenState();
}

class _ChallengeInputScreenState extends State<ChallengeInputScreen> {
  static const _articleOptions = ['UN', 'UNE'];
  static const _prepositionOptions = ['SUR', 'DANS'];

  final _formKey = GlobalKey<FormState>();
  final _forbiddenWords = <String>['Poulet', 'Volaille', 'Oiseau'];
  final _challenges = <Challenge>[];

  bool _isLoading = true;
  int _challengeCount = 0;

  @override
  void initState() {
    super.initState();
    _loadChallenges();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _loadChallenges({bool showLoader = true}) async {
    if (showLoader) {
      setState(() => _isLoading = true);
    }

    try {
      final gameCode =
          await SharedPreferencesHelper.getString('gameSessionId') ?? '';
      final userId = await SharedPreferencesHelper.getInt('id');

      if (gameCode.isEmpty || userId == null) {
        setState(() {
          _challenges.clear();
          _challengeCount = 0;
          _isLoading = false;
        });
        return;
      }

      final response =
          await PictApi.get('${PictApi.GAME_SESSIONS}/$gameCode');

      final ownChallenges = <Challenge>[];
      var count = 0;
      final rawChallenges = response['challenges'] as List<dynamic>?;
      if (rawChallenges != null) {
        for (final entry in rawChallenges) {
          if (entry['challenger_id'] == userId) {
            ownChallenges.add(Challenge.fromJson(entry));
            count++;
          }
        }
      }

      setState(() {
        _challenges
          ..clear()
          ..addAll(ownChallenges);
        _challengeCount = count;
        _isLoading = false;
      });
    } catch (error) {
      if (mounted) {
        showToast(context, 'Une erreur est survenue.');
      }
      setState(() => _isLoading = false);
    }
  }

  Future<void> _submitChallenge(_ChallengeDraft draft) async {
    try {
      final gameCode =
          await SharedPreferencesHelper.getString('gameSessionId') ?? '';
      await PictApi.postChallenge(
        '${PictApi.GAME_SESSIONS}/$gameCode/challenges',
        {
          'first_word': draft.articleOne.toLowerCase(),
          'second_word': draft.firstWord.toLowerCase(),
          'third_word': draft.preposition.toLowerCase(),
          'fourth_word': draft.articleTwo.toLowerCase(),
          'fifth_word': draft.secondWord.toLowerCase(),
          'forbidden_words': _forbiddenWords,
        },
      );

      if (!mounted) return;
      await _loadChallenges();
      _showSuccessDialog();
    } catch (error) {
      if (!mounted) return;
      showToastError(context, 'Impossible de créer le challenge.');
      if (error.toString().contains('not in the challenge')) {
        _moveToDrawingPhase();
      }
    }
  }

  void _moveToDrawingPhase() {
    showToastBlack(context, 'La partie a commencé.');
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const ChallengeDrawScreen()),
    );
  }

  Future<void> _logout() async {
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Déconnexion'),
        content: const Text('Êtes-vous sûr de vouloir vous déconnecter ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Déconnecter'),
          ),
        ],
      ),
    );

    if (shouldLogout != true) {
      return;
    }

    await SharedPreferencesHelper.clearData();
    if (!mounted) return;

    showToast(context, 'Vous êtes déconnecté.');
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (_) => false,
    );
  }

  void _showComposer() {
    const draft = _ChallengeDraft(
      articleOne: 'UN',
      firstWord: '',
      preposition: 'SUR',
      articleTwo: 'UN',
      secondWord: '',
    );

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return _ChallengeComposerSheet(
          formKey: _formKey,
          draft: draft,
          onSubmit: (updatedDraft) {
            Navigator.of(sheetContext).pop();
            _submitChallenge(updatedDraft);
          },
        );
      },
    );
  }

  void _showSuccessDialog() {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: PictConstants.PictSurface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text(
          'Challenge créé !',
          style: TextStyle(
            fontWeight: FontWeight.w800,
            color: PictConstants.PictSecondary,
          ),
          textAlign: TextAlign.center,
        ),
        content: const Text(
          'Votre challenge a été ajouté avec succès.',
          textAlign: TextAlign.center,
          style: TextStyle(color: PictConstants.PictGrey),
        ),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          MyButton(
            onPressed: () => Navigator.pop(context),
            text: 'Fermer',
            icon: Icons.check,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text('Atelier des challenges'),
        actions: [
          IconButton(
            onPressed: _logout,
            icon: const Icon(Icons.logout_rounded),
          ),
        ],
      ),
      body: PictGradientBackground(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 100, 20, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _ChallengeIntro(
                  challengeCount: _challengeCount,
                  onCreate: _challengeCount >= 3 ? null : _showComposer,
                ),
                const SizedBox(height: 24),
                Expanded(
                  child: _isLoading
                      ? const Center(child: MyLoader())
                      : _challengeCount == 0
                          ? _EmptyChallenges(onCreatePressed: _showComposer)
                          : ListView.builder(
                              padding: const EdgeInsets.only(bottom: 24),
                              itemCount: _challenges.length,
                              itemBuilder: (context, index) {
                                final item = _challenges[index];
                                final sentence =
                                    '${item.firstWord} ${item.secondWord} ${item.thirdWord} ${item.fourthWord} ${item.fifthWord}'.trim();
                                final forbidden =
                                    List<String>.from(jsonDecode(item.forbiddenWords));
                                return buildChallengeCard(
                                  index + 1,
                                  sentence,
                                  forbidden,
                                );
                              },
                            ),
                ),
                if (_challengeCount < 3) ...[
                  const SizedBox(height: 16),
                  MyButton(
                    onPressed: _showComposer,
                    text: 'Ajouter un challenge',
                    icon: Icons.auto_fix_high,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ChallengeIntro extends StatelessWidget {
  const _ChallengeIntro({
    required this.challengeCount,
    required this.onCreate,
  });

  final int challengeCount;
  final VoidCallback? onCreate;

  @override
  Widget build(BuildContext context) {
    final remaining = (3 - challengeCount).clamp(0, 3);
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        color: PictConstants.PictSurface.withOpacity(0.85),
        border: Border.all(color: PictConstants.PictPrimary.withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
            color: PictConstants.PictPrimary.withOpacity(0.25),
            blurRadius: 30,
            offset: const Offset(0, 18),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Vos défis imaginés',
            style: TextStyle(
              color: PictConstants.PictSecondary,
              fontSize: 22,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            challengeCount >= 3
                ? 'Vous avez proposé le nombre maximum de challenges. Préparez-vous à dessiner !'
                : 'Encore $remaining challenge${remaining > 1 ? 's' : ''} pour compléter votre contribution.',
            style: TextStyle(color: Colors.white.withOpacity(0.65)),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(18),
                  gradient: const LinearGradient(
                    colors: [PictConstants.PictPrimary, PictConstants.PictAccent],
                  ),
                ),
                child: Text(
                  '$challengeCount / 3',
                  style: const TextStyle(
                    color: PictConstants.PictSecondary,
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                  ),
                ),
              ),
              const Spacer(),
              if (onCreate != null)
                MyButton(
                  onPressed: onCreate,
                  text: 'Créer un challenge',
                  icon: Icons.add,
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _EmptyChallenges extends StatelessWidget {
  const _EmptyChallenges({required this.onCreatePressed});

  final VoidCallback onCreatePressed;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 360,
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(32),
          color: PictConstants.PictSurfaceVariant.withOpacity(0.9),
          border: Border.all(color: PictConstants.PictAccent.withOpacity(0.3)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.auto_awesome, size: 80, color: PictConstants.PictAccent),
            const SizedBox(height: 16),
            const Text(
              'Aucun challenge créé',
              style: TextStyle(
                color: PictConstants.PictSecondary,
                fontWeight: FontWeight.w800,
                fontSize: 22,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              'Lancez l\'imagination de vos coéquipiers en proposant un premier défi.',
              style: TextStyle(color: Colors.white.withOpacity(0.7)),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 28),
            MyButton(
              onPressed: onCreatePressed,
              text: 'Créer un challenge',
              icon: Icons.lightbulb,
            ),
          ],
        ),
      ),
    );
  }
}

class _ChallengeComposerSheet extends StatefulWidget {
  const _ChallengeComposerSheet({
    required this.formKey,
    required this.draft,
    required this.onSubmit,
  });

  final GlobalKey<FormState> formKey;
  final _ChallengeDraft draft;
  final ValueChanged<_ChallengeDraft> onSubmit;

  @override
  State<_ChallengeComposerSheet> createState() => _ChallengeComposerSheetState();
}

class _ChallengeComposerSheetState extends State<_ChallengeComposerSheet> {
  late _ChallengeDraft _draft = widget.draft;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            PictConstants.PictSurface,
            PictConstants.PictSurfaceVariant,
          ],
        ),
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      padding: EdgeInsets.only(
        left: 28,
        right: 28,
        bottom: MediaQuery.of(context).viewInsets.bottom + 32,
        top: 28,
      ),
      child: Form(
        key: widget.formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Nouveau challenge',
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
              _ArticleSelector(
                title: 'Article',
                value: _draft.articleOne,
                onChanged: (value) => setState(() => _draft = _draft.copyWith(articleOne: value)),
              ),
              const SizedBox(height: 12),
              _WordField(
                label: 'Premier mot',
                initialValue: _draft.firstWord,
                onChanged: (value) => _draft = _draft.copyWith(firstWord: value),
              ),
              const SizedBox(height: 12),
              _ArticleSelector(
                title: 'Préposition',
                options: _ChallengeInputScreenState._prepositionOptions,
                value: _draft.preposition,
                onChanged: (value) => setState(() => _draft = _draft.copyWith(preposition: value)),
              ),
              const SizedBox(height: 12),
              _ArticleSelector(
                title: 'Article',
                value: _draft.articleTwo,
                onChanged: (value) => setState(() => _draft = _draft.copyWith(articleTwo: value)),
              ),
              const SizedBox(height: 12),
              _WordField(
                label: 'Deuxième mot',
                initialValue: _draft.secondWord,
                onChanged: (value) => _draft = _draft.copyWith(secondWord: value),
              ),
              const SizedBox(height: 24),
              MyButton(
                onPressed: () {
                  if (widget.formKey.currentState?.validate() ?? false) {
                    widget.onSubmit(_draft);
                  }
                },
                text: 'Créer le challenge',
                icon: Icons.check_circle,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ArticleSelector extends StatelessWidget {
  const _ArticleSelector({
    required this.title,
    required this.value,
    required this.onChanged,
    this.options = _ChallengeInputScreenState._articleOptions,
  });

  final String title;
  final String value;
  final List<String> options;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
                fontWeight: FontWeight.w600,
                color: PictConstants.PictSecondary,
              ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: options
              .map(
                (option) => ChoiceChip(
                  label: Text(option),
                  selected: option == value,
                  onSelected: (_) => onChanged(option),
                  labelStyle: TextStyle(
                    color: option == value
                        ? PictConstants.PictSecondary
                        : Colors.white70,
                    fontWeight: FontWeight.w600,
                  ),
                  selectedColor: PictConstants.PictPrimary,
                  backgroundColor: Colors.white.withOpacity(0.08),
                  side: BorderSide(
                    color: option == value
                        ? PictConstants.PictPrimary
                        : Colors.white24,
                  ),
                ),
              )
              .toList(),
        ),
      ],
    );
  }
}

class _WordField extends StatefulWidget {
  const _WordField({
    required this.label,
    required this.initialValue,
    required this.onChanged,
  });

  final String label;
  final String initialValue;
  final ValueChanged<String> onChanged;

  @override
  State<_WordField> createState() => _WordFieldState();
}

class _WordFieldState extends State<_WordField> {
  late final TextEditingController _controller =
      TextEditingController(text: widget.initialValue);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: _controller,
      decoration: InputDecoration(
        labelText: widget.label,
        labelStyle: const TextStyle(color: PictConstants.PictSecondary),
      ),
      textCapitalization: TextCapitalization.sentences,
      onChanged: widget.onChanged,
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Champ requis';
        }
        return null;
      },
    );
  }
}

class _ChallengeDraft {
  const _ChallengeDraft({
    required this.articleOne,
    required this.firstWord,
    required this.preposition,
    required this.articleTwo,
    required this.secondWord,
  });

  final String articleOne;
  final String firstWord;
  final String preposition;
  final String articleTwo;
  final String secondWord;

  _ChallengeDraft copyWith({
    String? articleOne,
    String? firstWord,
    String? preposition,
    String? articleTwo,
    String? secondWord,
  }) {
    return _ChallengeDraft(
      articleOne: articleOne ?? this.articleOne,
      firstWord: firstWord ?? this.firstWord,
      preposition: preposition ?? this.preposition,
      articleTwo: articleTwo ?? this.articleTwo,
      secondWord: secondWord ?? this.secondWord,
    );
  }
}
