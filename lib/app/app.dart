import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import '../splash.dart';
import '../utils/constants.dart';
import 'app_theme.dart';

class PictioniaryApp extends StatelessWidget {
  const PictioniaryApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      onGenerateTitle: (context) => PictConstants.appName,
      title: PictConstants.appName,
      theme: AppTheme.light(),
      locale: const Locale('fr', 'FR'),
      supportedLocales: const [Locale('en'), Locale('fr')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: const SplashScreen(),
    );
  }
}
