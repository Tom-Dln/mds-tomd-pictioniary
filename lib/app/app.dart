import 'package:flutter/material.dart';

import '../splash.dart';
import '../utils/constants.dart';
import 'app_theme.dart';

class PictioniaryApp extends StatelessWidget {
  const PictioniaryApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: PictConstants.appName,
      theme: AppTheme.light(),
      home: const SplashScreen(),
    );
  }
}
