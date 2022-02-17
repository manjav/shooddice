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

    return Stack(
      children: [
        Center(
            heightFactor: 0.5,
            child: Text(
              text,
              textAlign: textAlign,
              style: style.copyWith(
                foreground: Paint()
                  ..strokeWidth = strokeWidth ?? 5.d
                  ..color = strokeColor ?? const Color(0xFF391591)
                  ..style = PaintingStyle.stroke,
              ),
            )),
        Center(
            heightFactor: 0.42,
            child: Text(text, textAlign: textAlign, style: style)),
      ],
    );
  }
}
