import 'package:flutter/material.dart';

void showToast(BuildContext context, String message) {
  _showSnackBar(context, message, Colors.black87);
}

void showToastBlack(BuildContext context, String message) {
  _showSnackBar(context, message, Colors.grey.shade800);
}

void showToastError(BuildContext context, String message) {
  _showSnackBar(context, message, Colors.red.shade700);
}

void _showSnackBar(BuildContext context, String message, Color background) {
  final messenger = ScaffoldMessenger.maybeOf(context);
  if (messenger == null) {
    return;
  }

  messenger
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: background,
        duration: const Duration(seconds: 2),
      ),
    );
}
