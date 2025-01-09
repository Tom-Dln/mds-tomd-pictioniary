import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:jwt_decoder/jwt_decoder.dart';

import '../utils/actions.dart';
import '../utils/api.dart';
import '../utils/constants.dart';
import '../utils/images.dart';
import '../utils/sharedpreferences.dart';
import '../widgets/MyButton.dart';
import '../widgets/pict_background.dart';
import 'login_step_2.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _passwordFocus = FocusNode();
  late final AnimationController _animationController = AnimationController(
    duration: const Duration(milliseconds: 700),
    vsync: this,
  )..forward();

  bool _isLoginMode = true;
  bool _isSubmitting = false;
  DateTime _lastBackPressed = DateTime.now();

  @override
  void dispose() {
    _animationController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    _passwordFocus.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isSubmitting = true);
    try {
      if (_isLoginMode) {
        await _login();
      } else {
        await _register();
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  Future<void> _register() async {
    final response = await PictApi.post(
      PictApi.REGISTER,
      {
        'name': _usernameController.text.trim(),
        'password': _passwordController.text,
      },
    );
    await SharedPreferencesHelper.saveInt('id', response['id']);
    await SharedPreferencesHelper.saveString('name', response['name']);
    await _login();
  }

  Future<void> _login() async {
    final response = await PictApi.post(
      PictApi.LOGIN,
      {
        'name': _usernameController.text.trim(),
        'password': _passwordController.text,
      },
    );
    final decoded = JwtDecoder.decode(response['token']);
    await SharedPreferencesHelper.saveString('token', response['token']);
    await SharedPreferencesHelper.saveInt('id', decoded['id']);
    await SharedPreferencesHelper.saveString('name', _usernameController.text);

    if (!mounted) return;
    Navigator.of(context).push(
      CupertinoPageRoute(builder: (_) => const LoginScreen2()),
    );
  }

  bool _shouldExitApp() {
    final now = DateTime.now();
    if (now.difference(_lastBackPressed) > const Duration(seconds: 2)) {
      _lastBackPressed = now;
      showToast('Appuyez de nouveau pour quitter');
      return false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        if (!didPop && _shouldExitApp()) {
          exit(0);
        }
      },
      child: Scaffold(
        extendBodyBehindAppBar: true,
        backgroundColor: Colors.transparent,
        body: PictGradientBackground(
          child: SafeArea(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 520),
                child: SingleChildScrollView(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 28, vertical: 32),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      ScaleTransition(
                        scale: CurvedAnimation(
                          parent: _animationController,
                          curve: Curves.easeOutBack,
                        ),
                        child: _AuthHero(isLoginMode: _isLoginMode),
                      ),
                      const SizedBox(height: 28),
                      Text(
                        _isLoginMode
                            ? 'Entrez dans l\'atelier créatif'
                            : 'Créons votre atelier',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: PictConstants.PictSecondary,
                          fontSize: 26,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _isLoginMode
                            ? 'Connectez-vous pour retrouver votre équipe et vos défis.'
                            : 'Choisissez un pseudo pour rejoindre les sessions.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.65),
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(height: 32),
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(32),
                          color: PictConstants.PictSurface.withOpacity(0.85),
                          border: Border.all(
                            color: PictConstants.PictPrimary.withOpacity(0.25),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color:
                                  PictConstants.PictPrimary.withOpacity(0.25),
                              blurRadius: 40,
                              offset: const Offset(0, 22),
                            ),
                          ],
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 32,
                        ),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              _AuthSwitch(
                                isLoginMode: _isLoginMode,
                                onChanged: (value) =>
                                    setState(() => _isLoginMode = value),
                              ),
                              const SizedBox(height: 28),
                              TextFormField(
                                controller: _usernameController,
                                textInputAction: TextInputAction.next,
                                decoration: const InputDecoration(
                                  labelText: 'Pseudo',
                                  prefixIcon: Icon(Icons.person_outline),
                                ),
                                onFieldSubmitted: (_) =>
                                    FocusScope.of(context)
                                        .requestFocus(_passwordFocus),
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return 'Veuillez entrer un pseudo';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 18),
                              TextFormField(
                                controller: _passwordController,
                                focusNode: _passwordFocus,
                                obscureText: true,
                                decoration: InputDecoration(
                                  labelText:
                                      _isLoginMode ? 'Mot de passe' : 'Créer un mot de passe',
                                  prefixIcon: const Icon(Icons.lock_outline),
                                ),
                                validator: (value) {
                                  if (value == null || value.length < 4) {
                                    return 'Mot de passe trop court';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 32),
                              MyButton(
                                onPressed: _isSubmitting ? null : _submit,
                                text: _isSubmitting
                                    ? 'Connexion en cours...'
                                    : _isLoginMode
                                        ? 'Se connecter'
                                        : "Créer mon compte",
                                icon: _isSubmitting
                                    ? Icons.autorenew
                                    : (_isLoginMode
                                        ? Icons.login
                                        : Icons.person_add_alt_1),
                              ),
                              const SizedBox(height: 16),
                              TextButton(
                                onPressed: _isLoginMode
                                    ? () => setState(() => _isLoginMode = false)
                                    : () => setState(() => _isLoginMode = true),
                                child: Text(
                                  _isLoginMode
                                      ? "Besoin d'un compte ? Inscrivez-vous"
                                      : 'Déjà membre ? Connectez-vous',
                                ),
                              ),
                              const Divider(height: 32, color: Colors.white12),
                              OutlinedButton.icon(
                                onPressed: () => exit(0),
                                icon: const Icon(Icons.close_rounded),
                                label: const Text('Fermer l\'application'),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _AuthHero extends StatelessWidget {
  const _AuthHero({required this.isLoginMode});

  final bool isLoginMode;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(32),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            PictConstants.PictPrimary,
            PictConstants.PictAccent,
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: PictConstants.PictAccent.withOpacity(0.35),
            blurRadius: 45,
            offset: const Offset(0, 24),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            height: 120,
            width: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withOpacity(0.15),
              border: Border.all(
                color: Colors.white.withOpacity(0.4),
                width: 1.2,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Image.asset(PictImages.appLogo),
            ),
          ),
          const SizedBox(height: 18),
          Text(
            isLoginMode
                ? 'Re-bienvenue créateur !'
                : 'Enchanté, futur artiste !',
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: PictConstants.PictSecondary,
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _AuthSwitch extends StatelessWidget {
  const _AuthSwitch({required this.isLoginMode, required this.onChanged});

  final bool isLoginMode;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        color: PictConstants.PictSurfaceVariant.withOpacity(0.7),
        border: Border.all(
          color: PictConstants.PictPrimary.withOpacity(0.2),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: _SwitchButton(
              label: 'Connexion',
              icon: Icons.login,
              isActive: isLoginMode,
              onTap: () => onChanged(true),
            ),
          ),
          Expanded(
            child: _SwitchButton(
              label: 'Inscription',
              icon: Icons.person_add,
              isActive: !isLoginMode,
              onTap: () => onChanged(false),
            ),
          ),
        ],
      ),
    );
  }
}

class _SwitchButton extends StatelessWidget {
  const _SwitchButton({
    required this.label,
    required this.icon,
    required this.isActive,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool isActive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          gradient: isActive
              ? const LinearGradient(
                  colors: [
                    PictConstants.PictPrimary,
                    PictConstants.PictAccent,
                  ],
                )
              : null,
          color: isActive ? null : Colors.transparent,
          boxShadow: isActive
              ? [
                  BoxShadow(
                    color: PictConstants.PictAccent.withOpacity(0.35),
                    blurRadius: 22,
                    offset: const Offset(0, 12),
                  ),
                ]
              : null,
        ),
        child: AnimatedDefaultTextStyle(
          duration: const Duration(milliseconds: 200),
          style: TextStyle(
            color:
                isActive ? PictConstants.PictSecondary : Colors.white70,
            fontWeight: FontWeight.w700,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                color:
                    isActive ? PictConstants.PictSecondary : Colors.white54,
              ),
              const SizedBox(width: 8),
              Text(label),
            ],
          ),
        ),
      ),
    );
  }
}
