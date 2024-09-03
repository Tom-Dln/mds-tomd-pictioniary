import 'package:flutter/material.dart';

import '../splash.dart';
import 'app_theme.dart';

class PictioniaryApp extends StatelessWidget {
  const PictioniaryApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Pictioniary',
      theme: AppTheme.light(),
      home: const SplashScreen(),
    );
  }
}
