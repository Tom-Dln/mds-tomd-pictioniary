// ignore_for_file: use_build_context_synchronously

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:toggle_switch/toggle_switch.dart';

import '../utils/actions.dart';
import '../utils/api.dart';
import '../utils/constants.dart';
import '../utils/dimens.dart';
import '../utils/images.dart';
import '../utils/sharedpreferences.dart';
import '../widgets/MyButton.dart';
import '../widgets/pict_background.dart';
import 'qr_code_scanner.dart';
import 'team_composition.dart';

class LoginScreen2 extends StatefulWidget {
  const LoginScreen2({super.key});

  @override
  State<LoginScreen2> createState() => _LoginScreen2State();
}

class _LoginScreen2State extends State<LoginScreen2> {
  final TextEditingController _codeController = TextEditingController();
  String _playerName = 'Invité';
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    _loadStoredName();
  }

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  Future<void> _loadStoredName() async {
    final storedName = await SharedPreferencesHelper.getString('name');
    setState(() => _playerName = storedName ?? 'Invité');
  }

  String get _greeting {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Bonjour';
    if (hour < 18) return 'Bon après-midi';
    return 'Bonsoir';
  }

  Future<void> _createSession() async {
    final shouldCreate = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Créer une nouvelle partie'),
        content: const Text(
          'Voulez-vous vraiment créer une nouvelle partie ? La session en cours sera fermée.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Annuler'),
          ),
          MyButton(
            onPressed: () => Navigator.pop(context, true),
            text: 'Créer la session',
            icon: Icons.auto_awesome,
          ),
        ],
      ),
    );

    if (shouldCreate != true) return;

    final response = await PictApi.post(PictApi.GAME_SESSIONS, {});
    await SharedPreferencesHelper.saveString(
      'gameSessionId',
      response['id'].toString(),
    );
    showToastBlack(context, 'Session créée.');
    if (!mounted) return;
    Navigator.of(context).push(
      CupertinoPageRoute(builder: (_) => const TeamCompositionScreen()),
    );
  }

  Future<void> _joinSession(String code) async {
    setState(() => _isProcessing = true);
    try {
      if (mounted) {
        showToastBlack(context, 'Recherche de la partie en cours...');
      }
      final details = await PictApi.get('${PictApi.GAME_SESSIONS}/$code');
      await _persistTeamAssignments(details);

      final userId = await SharedPreferencesHelper.getInt('id') ?? 0;
      if (userId == details['red_player_1'] ||
          userId == details['red_player_2'] ||
          userId == details['blue_player_1'] ||
          userId == details['blue_player_2'] ||
          userId == details['player_id']) {
        await SharedPreferencesHelper.saveString('gameSessionId', code);
        if (mounted) {
          showToastBlack(
            context,
            userId == details['player_id']
                ? 'Vous êtes le maître de cette partie.'
                : 'Vous avez rejoint la partie.',
          );
          Navigator.of(context).push(
            CupertinoPageRoute(builder: (_) => const TeamCompositionScreen()),
          );
        }
        return;
      }

      final master = await PictApi.get('${PictApi.REGISTER}/${details['player_id']}');
      final bool? selectedRed = await _selectTeam(master['name']);
      if (selectedRed == null) {
        return;
      }

      final teamAvailable = await _validateTeamAvailability(
        joinAsRed: selectedRed,
      );
      if (!teamAvailable) {
        return;
      }

      await SharedPreferencesHelper.saveString('gameSessionId', code);
      await PictApi.post(
        '${PictApi.GAME_SESSIONS}/$code/join',
        {'color': selectedRed ? 'red' : 'blue'},
      );
      showToastBlack(context, 'Session rejointe.');
      if (!mounted) return;
      Navigator.of(context).push(
        CupertinoPageRoute(builder: (_) => const TeamCompositionScreen()),
      );
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }

  Future<void> _persistTeamAssignments(Map<String, dynamic> details) async {
    await SharedPreferencesHelper.saveInt(
      'red_player_1',
      details['red_player_1'] ?? 0,
    );
    await SharedPreferencesHelper.saveInt(
      'red_player_2',
      details['red_player_2'] ?? 0,
    );
    await SharedPreferencesHelper.saveInt(
      'blue_player_1',
      details['blue_player_1'] ?? 0,
    );
    await SharedPreferencesHelper.saveInt(
      'blue_player_2',
      details['blue_player_2'] ?? 0,
    );
    await SharedPreferencesHelper.saveString(
      'game_phase_start_time',
      details['game_phase_start_time'] ?? '',
    );
  }

  Future<bool> _validateTeamAvailability({
    required bool joinAsRed,
  }) async {
    final redOne = await SharedPreferencesHelper.getInt('red_player_1') ?? 0;
    final redTwo = await SharedPreferencesHelper.getInt('red_player_2') ?? 0;
    final blueOne = await SharedPreferencesHelper.getInt('blue_player_1') ?? 0;
    final blueTwo = await SharedPreferencesHelper.getInt('blue_player_2') ?? 0;

    if (joinAsRed && redOne != 0 && redTwo != 0) {
      showToast(context, "L'équipe rouge est complète.");
      return false;
    }
    if (!joinAsRed && blueOne != 0 && blueTwo != 0) {
      showToast(context, "L'équipe bleue est complète.");
      return false;
    }
    return true;
  }

  Future<bool?> _selectTeam(String masterName) async {
    bool selectionIsRed = true;
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Rejoindre une session'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Voulez-vous vraiment rejoindre la partie de $masterName ? Vous perdrez toute partie en cours.',
            ),
            const SizedBox(height: PictDimens.pictDefaultSpace),
            ToggleSwitch(
              minWidth: 120,
              cornerRadius: 20,
              totalSwitches: 2,
              initialLabelIndex: 0,
              activeBgColors: const [
                [PictConstants.PictPrimary],
                [PictConstants.PictRed],
              ],
              inactiveBgColor: PictConstants.PictSurfaceVariant,
              activeFgColor: PictConstants.PictSecondary,
              inactiveFgColor: Colors.white,
              labels: const ['Bleu', 'Rouge'],
              onToggle: (index) => selectionIsRed = index == 1,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Annuler'),
          ),
          MyButton(
            onPressed: () => Navigator.pop(context, selectionIsRed),
            text: 'Rejoindre',
            icon: Icons.sports_esports,
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
      body: PictGradientBackground(
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                padding:
                    const EdgeInsets.symmetric(horizontal: 28, vertical: 32),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 720),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '$_greeting, $_playerName',
                                    style: const TextStyle(
                                      color: PictConstants.PictSecondary,
                                      fontWeight: FontWeight.w800,
                                      fontSize: 26,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Choisissez votre prochaine aventure : créez une session ou rejoignez vos coéquipiers.',
                                    style: TextStyle(
                                      color: Colors.white.withOpacity(0.65),
                                      fontSize: 15,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (constraints.maxWidth > 600)
                              Container(
                                padding: const EdgeInsets.all(18),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: const LinearGradient(
                                    colors: [
                                      PictConstants.PictPrimary,
                                      PictConstants.PictAccent,
                                    ],
                                  ),
                                ),
                                child: Image.asset(
                                  PictImages.appLogo,
                                  height: 64,
                                  width: 64,
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 32),
                        Wrap(
                          spacing: 24,
                          runSpacing: 24,
                          children: [
                            _ActionCard(
                              title: 'Créer une session',
                              description:
                                  'Lancez une nouvelle partie et invitez vos amis à rejoindre votre équipe.',
                              icon: Icons.auto_awesome,
                              accentColor: PictConstants.PictAccent,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Un code sera généré automatiquement pour partager la partie.',
                                    style: TextStyle(
                                      color: Colors.white.withOpacity(0.75),
                                    ),
                                  ),
                                  const SizedBox(height: 24),
                                  MyButton(
                                    onPressed:
                                        _isProcessing ? null : _createSession,
                                    text: _isProcessing
                                        ? 'Création en cours...'
                                        : 'Créer une session',
                                    icon: _isProcessing
                                        ? Icons.hourglass_top
                                        : Icons.auto_fix_high,
                                  ),
                                ],
                              ),
                            ),
                            _ActionCard(
                              title: 'Rejoindre une session',
                              description:
                                  'Saisissez ou scannez le code de la partie pour rejoindre votre équipe.',
                              icon: Icons.group_work,
                              accentColor: PictConstants.PictPrimary,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  TextField(
                                    controller: _codeController,
                                    textCapitalization: TextCapitalization.characters,
                                    decoration: const InputDecoration(
                                      labelText: 'Code de la partie',
                                      hintText: 'Ex: ABC123',
                                      prefixIcon: Icon(Icons.key_outlined),
                                    ),
                                  ),
                                  const SizedBox(height: 20),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: MyButton(
                                          onPressed: _codeController.text.isEmpty
                                              ? null
                                              : () => _joinSession(
                                                    _codeController.text.trim(),
                                                  ),
                                          text: 'Rejoindre',
                                          icon: Icons.login,
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      OutlinedButton(
                                        onPressed: () async {
                                          final code = await Navigator.of(context).push<String>(
                                            CupertinoPageRoute(
                                              builder: (_) => const QrCodeScannerScreen(),
                                            ),
                                          );
                                          if (code != null) {
                                            _codeController.text = code;
                                            await _joinSession(code);
                                          }
                                        },
                                        child: const Icon(Icons.qr_code_scanner),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _ActionCard extends StatelessWidget {
  const _ActionCard({
    required this.title,
    required this.description,
    required this.icon,
    required this.accentColor,
    required this.child,
  });

  final String title;
  final String description;
  final IconData icon;
  final Color accentColor;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 320,
      child: Container(
        padding: const EdgeInsets.all(28),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(32),
          color: PictConstants.PictSurface.withOpacity(0.85),
          border: Border.all(color: accentColor.withOpacity(0.35)),
          boxShadow: [
            BoxShadow(
              color: accentColor.withOpacity(0.25),
              blurRadius: 35,
              offset: const Offset(0, 18),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  height: 48,
                  width: 48,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [accentColor, accentColor.withOpacity(0.5)],
                    ),
                  ),
                  child: Icon(icon, color: PictConstants.PictSecondary),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      color: PictConstants.PictSecondary,
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              description,
              style: TextStyle(
                color: Colors.white.withOpacity(0.7),
                height: 1.4,
              ),
            ),
            const SizedBox(height: 24),
            child,
          ],
        ),
      ),
    );
  }
}
