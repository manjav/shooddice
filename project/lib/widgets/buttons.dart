import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:project/theme/themes.dart';
import 'package:project/utils/sounds.dart';
import 'package:project/utils/utils.dart';

class BumpedButton extends StatefulWidget {
  final bool? isEnable;
  final Widget? content;
  final EdgeInsets? padding;
  final List<Color>? colors;
  final Function()? onTap;
  final double? cornerRadius;
  final Widget? errorMessage;

  const BumpedButton(
      {Key? key,
      this.onTap,
      this.isEnable,
      this.content,
      this.padding,
      this.colors,
      this.errorMessage,
      this.cornerRadius})
      : super(key: key);
  @override
  _BumpedButtonState createState() => _BumpedButtonState();
}

class _BumpedButtonState extends State<BumpedButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    var enable = widget.isEnable ?? true;
    var padding = widget.padding ?? EdgeInsets.fromLTRB(10.d, 8.d, 10.d, 12.d);
    if (_isPressed && enable) {
      padding = padding.copyWith(
          top: padding.top + 2.d, bottom: padding.bottom - 2.d);
    }
    return GestureDetector(
        onTap: () {
          if (enable) {
            Sound.play("button-up");
            widget.onTap?.call();
          } else if (widget.errorMessage != null) {
            Rout.push(context, widget.errorMessage!, barrierDismissible: true);
          }
          _isPressed = false;
          setState(() {});
        },
        onTapDown: (details) {
          if (enable) Sound.play("button-down");
          _isPressed = true;
          setState(() {});
        },
        onTapCancel: () {
          if (enable) Sound.play("button-up");
          _isPressed = false;
          setState(() {});
        },
        child: Container(
            padding: padding,
            child: widget.content ?? const SizedBox(),
            decoration: ButtonDecor(widget.colors ?? TColors.white.value,
                widget.cornerRadius ?? 18.d, enable, _isPressed),
            width: 144.d,
            height: 52.d));
  }
}

class ButtonDecor extends Decoration {
  final bool isEnable;
  final bool isPressed;
  final List<Color> colors;
  final double cornerRadius;

  const ButtonDecor(
      this.colors, this.cornerRadius, this.isEnable, this.isPressed);

  @override
  BoxPainter createBoxPainter([VoidCallback? onChanged]) {
    return _ButtonDecorationPainter(colors, cornerRadius, isEnable, isPressed);
  }
}

class _ButtonDecorationPainter extends BoxPainter {
  final _mainPaint = Paint()..style = PaintingStyle.fill;
  final _overPaint = Paint()..style = PaintingStyle.fill;
  final _shadowPaint = Paint()..style = PaintingStyle.fill;

  final List<Color> colors;
  final double cornerRadius;
  bool isPressed = false;
  bool isEnable = true;

  _ButtonDecorationPainter(
      this.colors, this.cornerRadius, this.isEnable, this.isPressed)
      : super() {
    _overPaint.color = isEnable
        ? colors[2]
        : Color.lerp(colors[2], const Color(0xFF8a8a8a), 0.80)!;
    _mainPaint.color = const Color(0xFF2A2141);
    _shadowPaint.color = const Color(0x22000000);
  }

  @override
  void paint(Canvas canvas, Offset offset, ImageConfiguration configuration) {
    var pressed = isPressed && isEnable;
    var size = configuration.size ?? const Size(200, 200);
    var radius = cornerRadius;
    var padding = 3.d;
    var thickness = 2.d;
    var mainRect = RRect.fromLTRBXY(offset.dx, offset.dy,
        offset.dx + size.width, offset.dy + size.height, radius, radius);
    var overRect = RRect.fromLTRBXY(
        offset.dx + padding,
        offset.dy + padding - (pressed ? 0 : thickness * 0.6),
        offset.dx + size.width - padding,
        offset.dy + size.height - padding - (pressed ? 0 : thickness),
        radius * 0.85,
        radius * 0.85);
    var shadowRect = RRect.fromLTRBXY(
        offset.dx,
        offset.dy,
        offset.dx + size.width,
        offset.dy + size.height + thickness + padding,
        radius * 1.1,
        radius * 1.1);

    _overPaint.shader = ui.Gradient.linear(Offset(offset.dx, offset.dy),
        Offset(offset.dx, offset.dy + size.height), [
      isEnable
          ? colors[0]
          : Color.lerp(colors[0], const Color(0xFF8a8a8a), 0.70)!,
      isEnable
          ? colors[1]
          : Color.lerp(colors[1], const Color(0xFF8a8a8a), 0.70)!
    ]);
    canvas.drawRRect(shadowRect, _shadowPaint);
    canvas.drawRRect(mainRect, _mainPaint);
    canvas.drawRRect(overRect, _overPaint);
  }
}
