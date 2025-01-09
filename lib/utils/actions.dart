import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

import 'constants.dart';
import 'dimens.dart';

enum ToastKind { normal, accent, error }

void showToast(String message) => _showToast(message, ToastKind.normal);

void showToastBlack(String message) => _showToast(message, ToastKind.accent);

void showToastError(String message) => _showToast(message, ToastKind.error);

void _showToast(String message, ToastKind kind) {
  final background = switch (kind) {
    ToastKind.normal => PictConstants.PictBlack,
    ToastKind.accent => Colors.black,
    ToastKind.error => PictConstants.PictRed,
  };

  Fluttertoast.showToast(
    msg: message,
    toastLength: Toast.LENGTH_SHORT,
    gravity: ToastGravity.BOTTOM,
    timeInSecForIosWeb: 1,
    backgroundColor: background,
    textColor: PictConstants.PictSecondary,
    fontSize: PictDimens.pictDefaultSize * 0.6,
  );
}
