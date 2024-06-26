import 'package:flutter/material.dart';
import 'package:robo9_mobile_app/Utilities/generic_dialog.dart';

Future<int> showFileDialog(BuildContext context, String filename) {
  return showGenericDialog<int>(
    context: context,
    title: 'File Option',
    content: 'Select [${filename}] for new route?',
    optionsBuilder: () => {
      'Confirm': DialogOption(title: 'Confirm', color: Colors.blue, value: 0),
      'Cancel': DialogOption(title: 'Cancel', color: Colors.grey, value: 1),
      'Delete': DialogOption(title: 'Delete', color: Colors.red, value: -1),
    },
  ).then(
    (value) => value ?? 1,
  );
}
