import 'package:flutter/material.dart';
import 'package:robo9_mobile_app/Utilities/generic_dialog.dart';

Future<void> showErrorDialog(
  BuildContext context,
  String text,
) {
  return showGenericDialog<void>(
    context: context,
    title: 'ERROR',
    content: text,
    optionsBuilder: () => {
      'OK': null,
    },
  );
}
