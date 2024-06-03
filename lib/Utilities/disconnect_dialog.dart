import 'package:flutter/material.dart';
import 'package:robo9_mobile_app/Utilities/generic_dialog.dart';

Future<bool> showDisconnectDialog(BuildContext context) {
  return showGenericDialog<bool>(
    context: context,
    title: 'Disconnect',
    content: 'Are you sure to disconnect?',
    optionsBuilder: () => {
      'No': false,
      'Yes': true,
    },
  ).then(
    (value) => value ?? false,
  );
}
