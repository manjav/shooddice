import 'dart:ui' as ui;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:numbers/utils/sounds.dart';
import 'package:numbers/utils/themes.dart';
import 'package:numbers/utils/utils.dart';

class Buttons {
  static Widget button(
      {Function()? onTap,
      bool isEnable = true,
      Widget? content,
      EdgeInsets? padding,
      List<Color>? colors,
      double? cornerRadius}) {
    return GestureDetector(
        onTap: () {
          if (isEnable) {
            Sound.play("tap");
            onTap?.call();
          }
        },
        child: Container(
            padding: padding ?? EdgeInsets.fromLTRB(10.d, 6.d, 10.d, 12.d),
            child: content ?? SizedBox(),
            decoration: CustomDecoration(
                colors ?? Themes.swatch[TColors.white]!,
                cornerRadius ?? 10.d,
                isEnable),
            width: 154.d,
            height: 52.d));
  }
}

class CustomDecoration extends Decoration {
  final bool isEnable;
  final List<Color> colors;
  final double cornerRadius;

  CustomDecoration(this.colors, this.cornerRadius, this.isEnable);
  @override
  BoxPainter createBoxPainter([VoidCallback? onChanged]) {
    return _CustomDecorationPainter(colors, cornerRadius, isEnable);
  }
}

class _CustomDecorationPainter extends BoxPainter {
  var _backPaint = Paint()
    ..color = Color(0xFF212527)
    ..style = PaintingStyle.fill;
  var _shadowPaint = Paint()
    ..color = Color(0x66000000)
    ..style = PaintingStyle.fill
    ..maskFilter = MaskFilter.blur(BlurStyle.normal, 1.5);
  final _mainPaint = Paint()..style = PaintingStyle.fill;
  var _overPaint = Paint()..style = PaintingStyle.fill;

  final List<Color> colors;
  final double cornerRadius;
  bool isEnable = true;
  _CustomDecorationPainter(this.colors, this.cornerRadius, bool isEnable)
      : super() {
    _mainPaint.color = colors[2];
    this.isEnable = isEnable;
  }

  @override
  void paint(Canvas canvas, Offset offset, ImageConfiguration configuration) {
    var s = 0.8.d;
    var b = 2.0.d;
    var _cr = cornerRadius;
    var r = RRect.fromLTRBXY(
        offset.dx,
        offset.dy,
        offset.dx + configuration.size!.width,
        offset.dy + configuration.size!.height,
        _cr * 1.2,
        _cr * 1.2);
    var sr = RRect.fromLTRBXY(
        r.left - s, r.top, r.right + s, r.bottom + s * 3, _cr * 1.2, _cr * 1.2);
    var mr = RRect.fromLTRBXY(
        r.left + b, r.top + b, r.right - b, r.bottom - b, _cr, _cr);
    var or = RRect.fromLTRBXY(
        r.left + b, r.top + b, r.right - b, r.bottom - b - 5.d, _cr, _cr);

    _overPaint = Paint()
      ..shader = ui.Gradient.linear(Offset(or.left, or.top),
          Offset(or.left, or.bottom), [colors[0], colors[1]]);

    canvas.drawRRect(sr, _shadowPaint);
    canvas.drawRRect(r, _backPaint);
    canvas.drawRRect(mr, _mainPaint);
    if (isEnable) canvas.drawRRect(or, _overPaint);
  }
}
