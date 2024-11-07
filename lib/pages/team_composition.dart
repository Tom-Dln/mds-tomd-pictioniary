import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/team_member.dart';
import '../utils/actions.dart';
import '../utils/api.dart';
import '../utils/sharedpreferences.dart';
import 'login_step_2.dart';

class TeamCompositionScreen extends StatefulWidget {
  const TeamCompositionScreen({super.key});

  @override
  State<TeamCompositionScreen> createState() => _TeamCompositionScreenState();
}

class _TeamCompositionScreenState extends State<TeamCompositionScreen> {
  final _redTeam = <TeamMember>[];
  final _blueTeam = <TeamMember>[];

  bool _isLoading = true;
  String _gameCode = '';
  Timer? _pollingTimer;

  @override
  void initState() {
    super.initState();
    _loadTeams(showLoader: true);
    _pollingTimer =
        Timer.periodic(const Duration(seconds: 6), (_) => _loadTeams());
  }

  @override
  void dispose() {
    _pollingTimer?.cancel();
    super.dispose();
  }

  Future<void> _loadTeams({bool showLoader = false}) async {
    if (showLoader && mounted) {
      setState(() => _isLoading = true);
    }
    _redTeam.clear();
    _blueTeam.clear();

    _gameCode = await SharedPreferencesHelper.getString('gameSessionId') ?? '';
    if (_gameCode.isEmpty) {
      if (!mounted) return;
      showToast(context, 'Code introuvable. Veuillez vous reconnecter.');
      Navigator.of(context).pushReplacement(
        CupertinoPageRoute(builder: (_) => const LoginScreen2()),
      );
      return;
    }

    final details = await PictApi.get('${PictApi.GAME_SESSIONS}/$_gameCode');
    await _persistTeamAssignments(details);

    await _populateTeam(details['red_player_1'], 'red', _redTeam);
    await _populateTeam(details['red_player_2'], 'red', _redTeam);
    await _populateTeam(details['blue_player_1'], 'blue', _blueTeam);
    await _populateTeam(details['blue_player_2'], 'blue', _blueTeam);

    if (!mounted) return;
    setState(() => _isLoading = false);
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
        content: const Text('Voulez-vous vraiment quitter ?'),
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

  Future<void> _showNextPhaseInfo() async {
    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Phase suivante à venir'),
        content: const Text(
          'La phase de challenge sera disponible dans une prochaine version.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Compris'),
          ),
        ],
      ),
    );
  }

  bool get _isTeamComplete =>
      [..._redTeam, ..._blueTeam].every((member) => member.id != 0);

  void _copyCode() {
    if (_gameCode.isEmpty) {
      showToast(context, 'Aucun code disponible.');
      return;
    }
    Clipboard.setData(ClipboardData(text: _gameCode));
    showToast(context, 'Code copié.');
  }

  void _showIncompleteWarning() {
    showToast(context, 'Les équipes ne sont pas complètes.');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: () => _loadTeams(showLoader: true),
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Salle de jeu actuelle',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _isTeamComplete
                                ? 'Les équipes sont prêtes.'
                                : 'En attente de joueurs.',
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  _gameCode.isEmpty ? 'Aucun code' : _gameCode,
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              TextButton.icon(
                                onPressed: _copyCode,
                                icon: const Icon(Icons.copy),
                                label: const Text('Copier'),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  _TeamCard(title: 'Équipe bleue', members: _blueTeam),
                  const SizedBox(height: 16),
                  _TeamCard(title: 'Équipe rouge', members: _redTeam),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _isTeamComplete
                          ? _showNextPhaseInfo
                          : _showIncompleteWarning,
                      icon: const Icon(Icons.play_arrow),
                      label: Text(
                        _isTeamComplete
                            ? 'Lancer la phase suivante'
                            : 'Attendre les joueurs',
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}

class _TeamCard extends StatelessWidget {
  const _TeamCard({required this.title, required this.members});

  final String title;
  final List<TeamMember> members;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            for (final member in members)
              _TeamMemberTile(
                member: member,
              ),
          ],
        ),
      ),
    );
  }
}

class _TeamMemberTile extends StatelessWidget {
  const _TeamMemberTile({required this.member});

  final TeamMember member;

  @override
  Widget build(BuildContext context) {
    final isWaiting = member.name == 'En attente';
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          CircleAvatar(
            child: Text(
              member.name.isNotEmpty ? member.name[0].toUpperCase() : '?',
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              isWaiting ? 'En attente' : member.name,
              style: const TextStyle(fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }
}
