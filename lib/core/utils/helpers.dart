import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import '../constants/app_strings.dart';

String friendlyError(Object error) {
  if (error is FirebaseException && error.message != null) {
    return error.message!;
  }

  final message = error.toString().replaceFirst('Exception: ', '').trim();
  if (message.isEmpty) {
    return AppStrings.genericError;
  }

  return message;
}

void showAppSnackBar(
  BuildContext context,
  String message, {
  bool isError = false,
}) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red.shade700 : Colors.teal.shade700,
      ),
    );
}
