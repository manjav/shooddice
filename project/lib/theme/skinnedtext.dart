import 'package:flutter/material.dart';
import 'package:project/utils/utils.dart';

class SkinnedText extends StatelessWidget {
  final String text;
  final TextStyle? style;
  final Color? strokeColor;
  final TextAlign? textAlign;
  final double? strokeWidth;

  const SkinnedText(
    this.text, {
    Key? key,
    this.style,
    this.strokeColor,
    this.textAlign,
    this.strokeWidth,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var style = this.style ??
        TextStyle(
            fontSize: 12.d,
            foreground: Paint()..color = Colors.white,
            decorationThickness: 2);

    return Text(text, style: style);
  }
}
