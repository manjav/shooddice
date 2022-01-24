import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:project/core/cell.dart';
import 'package:project/utils/utils.dart';

class Widgets {
  static Widget cell(ThemeData theme, int value, {double size = 12}) {
    return Container(
        padding: EdgeInsets.only(bottom: size * 0.4),
        alignment: Alignment.center,
        child: SVG.show("n$value", size * 1.9),
        decoration: CellDecoration(value, size),
        width: 154.d,
        height: 52.d);
  }
}

class CellDecoration extends Decoration {
  final int value;
  final double size;
  const CellDecoration(this.value, this.size);
  @override
  BoxPainter createBoxPainter([VoidCallback? onChanged]) {
    return _CellDecorationPainter(value, size);
  }
}

class _CellDecorationPainter extends BoxPainter {
  final _shadowPaint = Paint()..style = PaintingStyle.fill;
  final _mainPaint = Paint()..style = PaintingStyle.fill;
  final _overPaint = Paint()..style = PaintingStyle.fill;

  final int value;
  final double size;
  _CellDecorationPainter(this.value, this.size) : super() {
    _shadowPaint.color = Cell.sideColors[0].withAlpha(100);
    _mainPaint.color = Cell.sideColors[value];
    _overPaint.shader = ui.Gradient.radial(
        Offset(size * 1.5, size * 1.3), size * 1.8, Cell.colors[value]);
  }

  @override
  void paint(Canvas canvas, Offset offset, ImageConfiguration configuration) {
    var cr = size;
    var b = size * 0.06;
    var mr = RRect.fromLTRBXY(
        offset.dx,
        offset.dy,
        offset.dx + configuration.size!.width,
        offset.dy + configuration.size!.height,
        cr,
        cr);
    var sr =
        RRect.fromLTRBXY(mr.left, mr.top, mr.right, mr.bottom + b * 3, cr, cr);
    var or = RRect.fromLTRBXY(mr.left + b * 2, mr.top + b * 2, mr.right - b * 2,
        mr.bottom - b * 2 - size * 0.3, cr * 0.9, cr * 0.9);

    canvas.drawRRect(sr, _shadowPaint);
    canvas.drawRRect(mr, _mainPaint);
    canvas.drawRRect(or, _overPaint);
  }
}
