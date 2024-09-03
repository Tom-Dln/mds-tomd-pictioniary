import 'dart:async';

import 'package:flutter/material.dart';

import 'app/app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await runZonedGuarded(
    () async {
      runApp(const PictioniaryApp());
    },
    (error, stackTrace) {
      debugPrint('Uncaught exception: ');
      debugPrint(error.toString());
    },
  );
}
