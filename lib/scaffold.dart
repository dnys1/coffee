import 'package:aws_common/aws_common.dart';
import 'package:coffee/theme.dart';
import 'package:flutter/material.dart';

/// The global [ScaffoldMessengerState], used to show snackbars.
final scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();

/// Shows an error snackbar, if possible, with the given [error].
void showErrorSnackBar(Object error) {
  if (error is AWSHttpException) {
    error = 'Error loading image. '
        "Please try again or view your favorites while you're offline :)";
  }
  WidgetsBinding.instance.addPostFrameCallback((_) {
    scaffoldMessengerKey.currentState
      ?..clearSnackBars()
      ..showSnackBar(
        SnackBar(
          content: Text(
            error.toString(),
            style: const TextStyle(color: Colors.white),
          ),
          backgroundColor: errorRed,
        ),
      );
  });
}
