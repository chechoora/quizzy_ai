import 'package:flutter/material.dart';

extension ContextUiExtensions on BuildContext {
  void showSnackBar(String message) {
    ScaffoldMessenger.of(this).showSnackBar(
      SnackBar(
        content: Text(message),
      ),
    );
  }
}

Future alert(
  BuildContext context, {
  Widget? title,
  Widget? content,
  Widget? textOK,
}) =>
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: title,
        content: SingleChildScrollView(child: content),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: textOK ?? Text(MaterialLocalizations.of(context).okButtonLabel),
          ),
        ],
      ),
    );
