import 'package:flutter/material.dart';
import 'package:poc_ai_quiz/view/widgets/app_dialog_button.dart';

Future alert(
  BuildContext context, {
  Widget? title,
  Widget? content,
  Widget? primary,
  Widget? secondary,
}) =>
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: title,
        content: SingleChildScrollView(child: content),
        actions: <Widget>[
          if (primary is! SizedBox)
            AppDialogButton.primary(
              text: MaterialLocalizations.of(context).okButtonLabel,
              onPressed: () {
                Navigator.of(context).pop(true);
              },
            ),
          if (secondary is! SizedBox)
            AppDialogButton.primary(
              text: MaterialLocalizations.of(context).calendarModeButtonLabel,
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
        ],
      ),
    );

void snackBar(
  BuildContext context, {
  required String message,
  Duration duration = const Duration(seconds: 4),
}) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(message),
      backgroundColor: Theme.of(context).colorScheme.error,
      duration: duration,
      action: SnackBarAction(
        label: 'Dismiss',
        textColor: Theme.of(context).colorScheme.onError,
        onPressed: () {
          ScaffoldMessenger.of(context).hideCurrentSnackBar();
        },
      ),
    ),
  );
}
