import 'package:flutter/material.dart';
import 'package:robo9_mobile_app/Utilities/generic_dialog.dart';

Future<bool> showDisconnectDialog(BuildContext context) {
  return showGenericDialog<bool>(
    context: context,
    title: 'Disconnect',
    content: 'Are you sure to disconnect?',
    optionsBuilder: () => {
      'No': DialogOption(title: 'No', color: Colors.red, value: false),
      'Yes': DialogOption(title: 'Yes', color: Colors.blue, value: true),
    },
  ).then(
    (value) => value ?? false,
  );
}
