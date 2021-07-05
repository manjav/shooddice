import 'dart:ui' as ui;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:numbers/utils/themes.dart';

class Buttons {
  static Widget button(
      {Function()? onTap,
      Widget? content,
      EdgeInsets? padding,
      List<Color>? colors,
      double? cornerRadius}) {
    return GestureDetector(
        onTap: onTap,
        child: Container(
          padding: padding ?? EdgeInsets.fromLTRB(10, 6, 10, 12),
          child: content ?? SizedBox(),
          decoration: CustomDecoration(
              colors ?? Themes.swatch[TColors.white]!, cornerRadius ?? 12),
          width: 154,
          height: 56,
        ));
  }
}

class CustomDecoration extends Decoration {
  final List<Color> colors;
  final double cornerRadius;
  CustomDecoration(this.colors, this.cornerRadius);
  @override
  BoxPainter createBoxPainter([VoidCallback? onChanged]) {
    return _CustomDecorationPainter(colors, cornerRadius);
  }
}

class _CustomDecorationPainter extends BoxPainter {
  var _backPaint = Paint()
    ..color = Color(0xFF212527)
    ..style = PaintingStyle.fill;
  var _shadowPaint = Paint()
    ..color = Color(0xFF000000)
    ..style = PaintingStyle.fill
    ..maskFilter = MaskFilter.blur(BlurStyle.outer, 2);
  static final _mainPaint = Paint()..style = PaintingStyle.fill;
  var _overPaint = Paint()..style = PaintingStyle.fill;

  final List<Color> colors;
  final double cornerRadius;
  // int state = 0;
  _CustomDecorationPainter(this.colors, this.cornerRadius) : super() {
    _mainPaint.color = colors[2];
  }

  @override
  void paint(Canvas canvas, Offset offset, ImageConfiguration configuration) {
    var b = 2.0;
    var _cr = cornerRadius;
    var r = RRect.fromLTRBXY(
        offset.dx,
        offset.dy,
        offset.dx + configuration.size!.width,
        offset.dy + configuration.size!.height,
        _cr * 1.1,
        _cr * 1.1);
    var mr = RRect.fromLTRBXY(
        r.left + b, r.top + b, r.right - b, r.bottom - b, _cr, _cr);
    var or = RRect.fromLTRBXY(
        r.left + b, r.top + b, r.right - b, r.bottom - b - 5, _cr, _cr);

    _overPaint = Paint()
      ..shader = ui.Gradient.linear(Offset(or.left, or.top),
          Offset(or.left, or.bottom), [colors[0], colors[1]]);

    canvas.drawRRect(r, _shadowPaint);
    canvas.drawRRect(r, _backPaint);
    canvas.drawRRect(mr, _mainPaint);
    canvas.drawRRect(or, _overPaint);
  }
}
