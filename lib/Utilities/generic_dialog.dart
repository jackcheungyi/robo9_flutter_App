import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class DialogOption {
  final String title;
  final Color color;
  final dynamic value;
  DialogOption({required this.title, required this.color, required this.value});
}

typedef DialogOptionBuilder<T> = Map<String, DialogOption> Function();

Future<T?> showGenericDialog<T>({
  required BuildContext context,
  required String title,
  required String content,
  required DialogOptionBuilder optionsBuilder,
}) {
  final options = optionsBuilder();
  return showDialog<T>(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: options.keys.map((optionTitle) {
          final value = options[optionTitle]?.value;
          return TextButton(
            onPressed: () {
              if (value != null) {
                Navigator.of(context).pop(value);
              } else {
                Navigator.of(context).pop();
              }
            },
            child: Text(
              optionTitle,
              style: TextStyle(color: options[optionTitle]!.color),
            ),
          );
        }).toList(),
      ).animate().fadeIn(curve: Curves.easeIn).scale(
          curve: Curves.easeInOutExpo); // runs after the above w/new duration
    },
  );
}
