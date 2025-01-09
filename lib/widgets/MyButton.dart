import 'package:flutter/material.dart';

import '../utils/constants.dart';

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
    final borderRadius = BorderRadius.circular(24);
    final isDisabled = onPressed == null;
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        padding: EdgeInsets.zero,
        backgroundColor: Colors.transparent,
        shadowColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: borderRadius),
      ),
      child: Ink(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isDisabled
                ? [
                    PictConstants.PictSurfaceVariant,
                    PictConstants.PictSurfaceVariant,
                  ]
                : const [
                    PictConstants.PictPrimary,
                    PictConstants.PictAccent,
                  ],
          ),
          borderRadius: borderRadius,
          boxShadow: [
            BoxShadow(
              color: isDisabled
                  ? Colors.transparent
                  : PictConstants.PictPrimary.withOpacity(0.3),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Container(
          constraints: const BoxConstraints(minHeight: 54),
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null) ...[
                Icon(
                  icon,
                  color: isDisabled
                      ? Colors.white38
                      : PictConstants.PictSecondary,
                ),
                const SizedBox(width: 8),
              ],
              Flexible(
                child: Text(
                  text,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: PictConstants.PictSecondary,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
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
    return ConstrainedBox(
      constraints: minSize
          ? const BoxConstraints(minWidth: 220, minHeight: 56)
          : const BoxConstraints(minHeight: 56),
      child: MyButton(
        onPressed: onPressed,
        text: text,
        icon: icon,
      ),
    );
  }
}
