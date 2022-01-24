import 'package:flutter/material.dart';
import 'package:project/utils/utils.dart';

class ChromeDecoration extends Decoration {
  final Color? color;
  final bool? showPins;
  const ChromeDecoration({this.color, this.showPins}) : super();
  @override
  BoxPainter createBoxPainter([VoidCallback? onChanged]) {
    return _ChromeDecorationPainter(color, showPins);
  }
}

class _ChromeDecorationPainter extends BoxPainter {
  final _mainPaint = Paint()..style = PaintingStyle.fill;
  final _overPaint = Paint()..style = PaintingStyle.fill;
  final _shadowPaint = Paint()..style = PaintingStyle.fill;
  final _circlePaint = Paint()..style = PaintingStyle.fill;

  final Color? color;
  final bool? showPins;
  _ChromeDecorationPainter(this.color, this.showPins) : super() {
    _overPaint.color = color ?? const Color(0xFF415361);
    _mainPaint.color = const Color(0xFF2A3137);
    _shadowPaint.color = const Color(0x22000000);
    _circlePaint.color = const Color(0x55000000);
  }

  @override
  void paint(Canvas canvas, Offset offset, ImageConfiguration configuration) {
    bool pins = showPins ?? true;
    var size = configuration.size ?? const Size(200, 200);
    var circleRadius = 4.d;
    var radius = 26.d;
    var padding = 2.d;
    var thickness = 4.d;
    var mainRect = RRect.fromLTRBXY(offset.dx, offset.dy,
        offset.dx + size.width, offset.dy + size.height, radius, radius);
    var overRect = RRect.fromLTRBXY(
        offset.dx + padding,
        offset.dy + padding,
        offset.dx + size.width - padding,
        offset.dy + size.height - thickness - padding,
        radius * 0.9,
        radius * 0.9);
    var shadowRect = RRect.fromLTRBXY(
        offset.dx,
        offset.dy,
        offset.dx + size.width,
        offset.dy + size.height + thickness,
        radius * 1.1,
        radius * 1.1);

    canvas.drawRRect(shadowRect, _shadowPaint);
    canvas.drawRRect(mainRect, _mainPaint);
    canvas.drawRRect(overRect, _overPaint);
    if (!pins) return;
    drawCircle(canvas, offset.dx + radius, offset.dy + radius, circleRadius);
    drawCircle(canvas, offset.dx + size.width - radius - circleRadius * 2,
        offset.dy + radius, circleRadius);
    drawCircle(canvas, offset.dx + radius,
        offset.dy + size.height - radius - circleRadius * 2, circleRadius);
    drawCircle(canvas, offset.dx + size.width - radius - circleRadius * 2,
        offset.dy + size.height - radius - circleRadius * 2, circleRadius);
  }

  void drawCircle(Canvas canvas, double x, double y, double redius) {
    var path = Path();
    var diameter = redius * 2;
    path.moveTo(
      x,
      y + diameter * 0.5000000,
    );
    path.cubicTo(
      x,
      y + diameter * 0.5431429,
      x + diameter * 0.01575000,
      y + diameter * 0.6250000,
      x + diameter * 0.01575000,
      y + diameter * 0.6250000,
    );
    path.cubicTo(
        x + diameter * 0.01575000,
        y + diameter * 0.6250000,
        x + diameter * 0.1071429,
        y + diameter * 0.2500000,
        x + diameter * 0.5000000,
        y + diameter * 0.2500000);
    path.cubicTo(
        x + diameter * 0.8928571,
        y + diameter * 0.2500000,
        x + diameter * 0.9842500,
        y + diameter * 0.6250000,
        x + diameter * 0.9842500,
        y + diameter * 0.6250000);
    path.cubicTo(
      x + diameter * 0.9842500,
      y + diameter * 0.6250000,
      x + diameter,
      y + diameter * 0.5431786,
      x + diameter,
      y + diameter * 0.5000000,
    );
    path.cubicTo(
      x + diameter,
      y + diameter * 0.2238571,
      x + diameter * 0.7761429,
      y,
      x + diameter * 0.5000000,
      y,
    );
    path.cubicTo(
      x + diameter * 0.2238571,
      y,
      x,
      y + diameter * 0.2238571,
      x,
      y + diameter * 0.5000000,
    );
    path.close();
    canvas.drawCircle(Offset(x + redius, y + redius), redius, _circlePaint);
    canvas.drawPath(path, _circlePaint);
  }
}
