import 'package:flutter/material.dart';

class ReusableText extends StatelessWidget {
  final String text;
  final double fontSize;
  final Color color;
  final TextDecoration decoration;

  const ReusableText({super.key, required this.text, required this.fontSize, required this.color, required this.decoration});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        fontFamily: 'Comfortaa',
        fontSize: fontSize,
        fontWeight: FontWeight.w700,
        color: color,
        decoration: decoration,
      ),
    );
  }
}
