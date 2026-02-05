import 'package:flutter/material.dart';
import 'package:poc_ai_quiz/l10n/localize.dart';
import 'package:poc_ai_quiz/util/theme/app_colors.dart';
import 'package:poc_ai_quiz/view/widgets/app_bottom_sheet.dart';
import 'package:poc_ai_quiz/view/widgets/app_dialog_button.dart';

Future alert(
  BuildContext context, {
  Widget? title,
  Widget? content,
  Widget? primary,
  Widget? secondary,
}) {
  final Widget primaryWidget;
  if (primary != null) {
    primaryWidget = primary;
  } else {
    primaryWidget = AppDialogButton.primary(
      text: MaterialLocalizations.of(context).okButtonLabel,
      onPressed: () {
        Navigator.of(context).pop(true);
      },
    );
  }
  final Widget secondaryWidget;
  if (secondary != null) {
    secondaryWidget = secondary;
  } else {
    secondaryWidget = AppDialogButton.primary(
      text: MaterialLocalizations.of(context).cancelButtonLabel,
      onPressed: () {
        Navigator.of(context).pop();
      },
    );
  }
  return showDialog(
    context: context,
    builder: (_) => AlertDialog(
      actionsAlignment: MainAxisAlignment.spaceBetween,
      title: title,
      content: SingleChildScrollView(child: content),
      actions: <Widget>[
        primaryWidget,
        secondaryWidget,
      ],
    ),
  );
}

void snackBar(
  BuildContext context, {
  required String message,
  Duration duration = const Duration(seconds: 4),
}) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(message),
      backgroundColor: AppColors.error100,
      duration: duration,
      action: SnackBarAction(
        label: localize(context).dismiss,
        textColor: AppColors.error500,
        onPressed: () {
          ScaffoldMessenger.of(context).hideCurrentSnackBar();
        },
      ),
    ),
  );
}

Future<T?> showAppBottomSheet<T>(
  BuildContext context, {
  required Widget title,
  required Widget button,
  AppBottomSheetVariant variant = AppBottomSheetVariant.positive,
  Widget? content,
}) {
  return showModalBottomSheet<T>(
    context: context,
    backgroundColor: Colors.transparent,
    builder: (_) => AppBottomSheet(
      title: title,
      button: button,
      variant: variant,
      content: content,
    ),
  );
}
