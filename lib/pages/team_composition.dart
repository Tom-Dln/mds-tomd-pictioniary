import 'dart:async';

import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../models/team_member.dart';
import '../utils/actions.dart';
import '../utils/api.dart';
import '../utils/constants.dart';
import '../utils/images.dart';
import '../utils/sharedpreferences.dart';
import '../widgets/MyButton.dart';
import '../widgets/myloader.dart';
import '../widgets/pict_background.dart';
import 'challenge_input.dart';
import 'challenge_show.dart';
import 'login_step_2.dart';

class TeamCompositionScreen extends StatefulWidget {
  const TeamCompositionScreen({super.key});

  @override
  State<TeamCompositionScreen> createState() => _TeamCompositionScreenState();
}

class _TeamCompositionScreenState extends State<TeamCompositionScreen>
    with SingleTickerProviderStateMixin {
  final _redTeam = <TeamMember>[];
  final _blueTeam = <TeamMember>[];
  late final AnimationController _animationController = AnimationController(
    duration: const Duration(milliseconds: 700),
    vsync: this,
  )..forward();

  bool _isLoading = true;
  String _gameCode = '';
  int _gameOwnerId = 0;
  int _currentUserId = 0;

  @override
  void initState() {
    super.initState();
    _loadTeams();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _loadTeams() async {
    setState(() => _isLoading = true);
    _redTeam.clear();
    _blueTeam.clear();

    _gameCode = await SharedPreferencesHelper.getString('gameSessionId') ?? '';
    _currentUserId = await SharedPreferencesHelper.getInt('id') ?? 0;
    if (_gameCode.isEmpty) {
      showToast('Code de partie introuvable. Veuillez vous reconnecter.');
      if (mounted) {
        Navigator.of(context).pushReplacement(
          CupertinoPageRoute(builder: (_) => const LoginScreen2()),
        );
      }
      return;
    }

    final details = await PictApi.get('${PictApi.GAME_SESSIONS}/$_gameCode');
    _gameOwnerId = details['player_id'] ?? 0;
    await _persistTeamAssignments(details);

    await _populateTeam(details['red_player_1'], 'red', _redTeam);
    await _populateTeam(details['red_player_2'], 'red', _redTeam);
    await _populateTeam(details['blue_player_1'], 'blue', _blueTeam);
    await _populateTeam(details['blue_player_2'], 'blue', _blueTeam);

    setState(() => _isLoading = false);

    final teamsComplete =
        [..._redTeam, ..._blueTeam].every((member) => member.id != 0);
    if (teamsComplete) {
      _promptStartGame();
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

  Future<void> _populateTeam(
    dynamic playerId,
    String type,
    List<TeamMember> team,
  ) async {
    if (playerId == null || playerId == 0) {
      team.add(TeamMember(id: 0, name: 'En attente', type: type));
      return;
    }
    final data = await PictApi.get('${PictApi.REGISTER}/$playerId');
    team.add(TeamMember.fromJson(data, type));
  }

  Future<void> _leaveGame() async {
    final shouldLeave = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Quitter la partie'),
        content: const Text('Êtes-vous sûr(e) de vouloir quitter la partie ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Non'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Quitter'),
          ),
        ],
      ),
    );

    if (shouldLeave != true) return;

    await PictApi.get('${PictApi.GAME_SESSIONS}/$_gameCode/leave');
    await SharedPreferencesHelper.removeData('gameSessionId');
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      CupertinoPageRoute(builder: (_) => const LoginScreen2()),
    );
  }

  Future<void> _promptStartGame() async {
    final shouldStart = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Lancer les challenges'),
        content: const Text(
          "L'équipe est au complet. Voulez-vous lancer les challenges maintenant ?",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Non'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(
              _currentUserId == _gameOwnerId ? 'Lancer' : 'Rejoindre',
            ),
          ),
        ],
      ),
    );

    if (shouldStart == true) {
      await _startChallenges();
    }
  }

  Future<void> _startChallenges() async {
    final status =
        await PictApi.get('${PictApi.GAME_SESSIONS}/$_gameCode/status');

    if (_currentUserId == _gameOwnerId && status['status'] == 'waiting') {
      await PictApi.post(
        '${PictApi.GAME_SESSIONS}/$_gameCode/start',
        {'status': 'challenge'},
      );
      showToast('Les challenges sont lancés! 🎉');
      if (!mounted) return;
      Navigator.of(context).push(
        CupertinoPageRoute(builder: (_) => const ChallengeInputScreen()),
      );
      return;
    }

    if (!mounted) return;
    if (status['status'] == 'challenge') {
      Navigator.of(context).push(
        CupertinoPageRoute(builder: (_) => const ChallengeInputScreen()),
      );
    } else if (status['status'] == 'drawing') {
      Navigator.of(context).push(
        CupertinoPageRoute(builder: (_) => const ChallengeDrawScreen()),
      );
    } else {
      showToast('Veuillez attendre que la partie soit lancée par le créateur.');
    }
  }

  void _showQrCode() {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return TweenAnimationBuilder<double>(
          tween: Tween(begin: 0, end: 1),
          duration: const Duration(milliseconds: 300),
          builder: (context, value, child) => Transform.translate(
            offset: Offset(0, (1 - value) * 60),
            child: Opacity(opacity: value, child: child),
          ),
          child: Container(
            height: MediaQuery.of(context).size.height * 0.75,
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 28),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  PictConstants.PictSurface,
                  PictConstants.PictSurfaceVariant,
                ],
              ),
              borderRadius: BorderRadius.vertical(top: Radius.circular(36)),
            ),
            child: Column(
              children: [
                Container(
                  width: 44,
                  height: 5,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Scanner le QR Code',
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                    color: PictConstants.PictSecondary,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Partagez cette clé avec vos coéquipiers pour les inviter instantanément.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.65),
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 36),
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(28),
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 25,
                        offset: const Offset(0, 18),
                      ),
                    ],
                  ),
                  child: QrImageView(
                    data: _gameCode,
                    version: QrVersions.auto,
                    size: 240,
                    embeddedImage: const AssetImage(PictImages.appLogo),
                    embeddedImageStyle: const QrEmbeddedImageStyle(
                      size: Size(56, 56),
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(18),
                    color: PictConstants.PictSurface.withOpacity(0.9),
                    border: Border.all(color: PictConstants.PictPrimary.withOpacity(0.3)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _gameCode,
                        style: const TextStyle(
                          color: PictConstants.PictSecondary,
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.2,
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          Clipboard.setData(ClipboardData(text: _gameCode));
                          showToast('Code copié !');
                        },
                        icon: const Icon(Icons.copy, color: PictConstants.PictAccent),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                MyButton(
                  onPressed: () => Navigator.pop(context),
                  text: 'Fermer',
                  icon: Icons.check,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  bool get _isTeamComplete =>
      [..._redTeam, ..._blueTeam].every((member) => member.id != 0);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text('Composition des équipes'),
        leading: IconButton(
          icon: const Icon(Icons.chevron_left),
          onPressed: () async {
            await SharedPreferencesHelper.removeData('gameSessionId');
            if (!mounted) return;
            Navigator.of(context).pushReplacement(
              CupertinoPageRoute(builder: (_) => const LoginScreen2()),
            );
          },
        ),
        actions: [
          IconButton(
            onPressed: _leaveGame,
            icon: const Icon(Icons.logout_rounded),
          ),
        ],
      ),
      body: PictGradientBackground(
        child: _isLoading
            ? const Center(child: MyLoader())
            : RefreshIndicator(
                onRefresh: _loadTeams,
                color: PictConstants.PictAccent,
                backgroundColor: PictConstants.PictSurface,
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(20, 120, 20, 40),
                  children: [
                    _Header(
                      code: _gameCode,
                      onShowQr: _showQrCode,
                      isTeamComplete: _isTeamComplete,
                      onStart: _isTeamComplete
                          ? _promptStartGame
                          : _showIncompleteWarning,
                    ),
                    const SizedBox(height: 32),
                    _TeamCard(
                      title: 'Équipe Néon',
                      gradientColors: const [
                        Color(0xFF38BDF8),
                        Color(0xFF6366F1),
                      ],
                      members: _blueTeam,
                      animation: _animationController,
                      accentIcon: Icons.water_drop,
                    ),
                    _TeamCard(
                      title: 'Équipe Incandescente',
                      gradientColors: const [
                        Color(0xFFF97316),
                        Color(0xFFEF4444),
                      ],
                      members: _redTeam,
                      animation: _animationController,
                      accentIcon: Icons.local_fire_department,
                    ),
                  ],
                ),
              ),
      ),
    );
  }

  void _showIncompleteWarning() {
    showToast('Veuillez attendre que les équipes soient complètes');
  }
}

class _Header extends StatelessWidget {
  const _Header({
    required this.code,
    required this.onShowQr,
    required this.isTeamComplete,
    required this.onStart,
  });

  final String code;
  final VoidCallback onShowQr;
  final bool isTeamComplete;
  final VoidCallback onStart;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(32),
        color: PictConstants.PictSurface.withOpacity(0.9),
        border: Border.all(color: Colors.white.withOpacity(0.06)),
        boxShadow: [
          BoxShadow(
            color: PictConstants.PictPrimary.withOpacity(0.3),
            blurRadius: 35,
            offset: const Offset(0, 20),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                height: 48,
                width: 48,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [
                      PictConstants.PictAccent,
                      PictConstants.PictPrimary,
                    ],
                  ),
                ),
                child: const Icon(Icons.groups, color: PictConstants.PictSecondary),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Salle de jeu actuelle',
                      style: TextStyle(
                        color: PictConstants.PictSecondary,
                        fontWeight: FontWeight.w700,
                        fontSize: 20,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      isTeamComplete
                          ? 'Les équipes sont prêtes !'
                          : 'En attente de joueurs supplémentaires',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.65),
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: onShowQr,
                icon: const Icon(Icons.qr_code_2, color: PictConstants.PictAccent),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: PictConstants.PictSurfaceVariant.withOpacity(0.8),
              border: Border.all(color: PictConstants.PictPrimary.withOpacity(0.25)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        code.isEmpty ? 'Aucun code' : code,
                        style: const TextStyle(
                          color: PictConstants.PictSecondary,
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.5,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Partagez ce code ou affichez le QR code pour inviter vos amis.',
                        style: TextStyle(color: Colors.white.withOpacity(0.6)),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: code));
                    showToast('Code copié !');
                  },
                  icon: const Icon(Icons.copy_all, color: PictConstants.PictSecondary),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          MyButton(
            onPressed: onStart,
            text: isTeamComplete
                ? 'Lancer la phase suivante'
                : 'Notifier les joueurs',
            icon: isTeamComplete ? Icons.rocket_launch : Icons.notifications_active,
          ),
        ],
      ),
    );
  }
}

class _TeamCard extends StatelessWidget {
  const _TeamCard({
    required this.title,
    required this.gradientColors,
    required this.members,
    required this.animation,
    required this.accentIcon,
  });

  final String title;
  final List<Color> gradientColors;
  final List<TeamMember> members;
  final AnimationController animation;
  final IconData accentIcon;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        return Transform.scale(
          scale: animation.value,
          child: Container(
            margin: const EdgeInsets.symmetric(vertical: 14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(32),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: gradientColors,
              ),
              boxShadow: [
                BoxShadow(
                  color: gradientColors.last.withOpacity(0.3),
                  blurRadius: 35,
                  offset: const Offset(0, 18),
                ),
              ],
            ),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
                  child: Row(
                    children: [
                      Icon(accentIcon, color: Colors.white, size: 26),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          title,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.3,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.08),
                    borderRadius: const BorderRadius.vertical(
                      bottom: Radius.circular(32),
                    ),
                  ),
                  child: Column(
                    children: [
                      for (int i = 0; i < members.length; i++)
                        _TeamMemberTile(
                          member: members[i],
                          accent: gradientColors,
                          isLast: i == members.length - 1,
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _TeamMemberTile extends StatelessWidget {
  const _TeamMemberTile({
    required this.member,
    required this.accent,
    required this.isLast,
  });

  final TeamMember member;
  final List<Color> accent;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    final accentColor = accent.last;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Colors.white.withOpacity(isLast ? 0 : 0.12),
          ),
        ),
      ),
      child: Row(
        children: [
          Container(
            height: 44,
            width: 44,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [accent.first, accent.last],
              ),
            ),
            alignment: Alignment.center,
            child: Text(
              member.name.isNotEmpty ? member.name[0].toUpperCase() : '?',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(width: 16),
          if (member.name == 'En attente')
            _WaitingIndicator(color: accentColor)
          else
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  member.name,
                  style: const TextStyle(
                    fontSize: 18,
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  member.type == 'red' ? 'Joueur incandescent' : 'Joueur néon',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.6),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}

class _WaitingIndicator extends StatelessWidget {
  const _WaitingIndicator({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: 1),
            duration: const Duration(seconds: 1),
            builder: (context, value, child) => Transform.rotate(
              angle: value * 2 * 3.14159,
              child: child,
            ),
            child: Icon(Icons.sync, size: 16, color: color.withOpacity(0.7)),
          ),
          const SizedBox(width: 8),
          DefaultTextStyle(
            style: TextStyle(
              color: color.withOpacity(0.7),
              fontWeight: FontWeight.w500,
            ),
            child: AnimatedTextKit(
              repeatForever: true,
              pause: const Duration(milliseconds: 150),
              animatedTexts: [
                FadeAnimatedText('En attente'),
                FadeAnimatedText('En attente.'),
                FadeAnimatedText('En attente..'),
                FadeAnimatedText('En attente...'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
