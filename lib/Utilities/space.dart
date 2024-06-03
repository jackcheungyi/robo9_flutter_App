import 'package:flutter/material.dart';

class Space extends StatelessWidget {
  final double height;
  final double width;

  const Space.Y(double y, {super.key})
      : height = y,
        width = 0;

  const Space.X(double x, {super.key})
      : width = x,
        height = 0;

  @override
  Widget build(BuildContext context) {
    return SizedBox(height: height, width: width);
  }
}