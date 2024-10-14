import 'package:flutter/material.dart';

class MyButton extends StatelessWidget {
  const MyButton({
    super.key,
    required this.onPressed,
    required this.text,
    this.icon,
  });

  final VoidCallback? onPressed;
  final String text;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    if (icon != null) {
      return ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon),
        label: Text(text),
      );
    }
    return ElevatedButton(
      onPressed: onPressed,
      child: Text(text),
    );
  }
}

class MyButtonWithIcon extends StatelessWidget {
  const MyButtonWithIcon({
    super.key,
    required this.onPressed,
    required this.icon,
    required this.text,
    this.minSize = false,
  });

  final VoidCallback onPressed;
  final IconData icon;
  final String text;
  final bool minSize;

  @override
  Widget build(BuildContext context) {
    return MyButton(
      onPressed: onPressed,
      text: text,
      icon: icon,
    );
  }
}
