import 'dart:math';
import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame/palette.dart';
import 'package:flutter/animation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:numbers/core/game.dart';

enum CellState { Init, Float, Falling, Fell, Fixed }

class Cell extends PositionComponent with HasGameRef<MyGame> {
  static final minSpeed = 0.01;
  static final maxSpeed = 0.8;
  static final border = 1.8;
  static final round = 7.0;
  static final firstRecord = 1024;
  static final firstBigRecord = 8;
  static int maxRandomValue = 3;
  static final colors = [
    PaletteEntry(Color(0xFF191C1D)),
    PaletteEntry(Color(0xFF9600FF)),
    PaletteEntry(Color(0xFFF0145A)),
    PaletteEntry(Color(0xFFFFBC15)),
    PaletteEntry(Color(0xFF21C985)),
    PaletteEntry(Color(0xFF00B0F0)),
    PaletteEntry(Color(0xFFE007B4)),
    PaletteEntry(Color(0xFF7EE024)),
    PaletteEntry(Color(0xFFFF5B8E)),
    PaletteEntry(Color(0xFFFF5518)),
    PaletteEntry(Color(0xFFACC723)),
    PaletteEntry(Color(0xFF6132D6)),
    PaletteEntry(Color(0xFFAC3674)),
    PaletteEntry(Color(0xFF8E7C58)),
    PaletteEntry(Color(0xFFE2DB21)),
    PaletteEntry(Color(0xFF0070C0))
  ];
  static final scales = [0, 1, 0.9, 0.75, 0.65, 0.55];
  static double diameter = 64.0;
  static double radius = diameter * 0.5;

  static double get strock => border + 2.4;
  static int getNextValue() => MyGame.random.nextInt(maxRandomValue) + 1;
  static int getScore(int value) => pow(2, value) as int;
  static final _center = Vector2(0, -3);

  bool matched = false;
  int hiddenMode = 0;
  int column = 0, row = 0, reward = 0, value = 0;
  Function(Cell)? onInit;
  CellState state = CellState.Init;
  static final RRect _backRect = RRect.fromLTRBXY(
      border - radius,
      border - radius,
      radius - border,
      radius - border,
      round * 1.3,
      round * 1.3);
  static final RRect _sideRect = RRect.fromLTRBXY(strock - radius,
      strock - radius, radius - strock, radius - strock, round, round);
  static final RRect _overRect = RRect.fromLTRBXY(strock - radius,
      strock - radius, radius - strock, radius - strock - 4.6, round, round);

  static final Paint _backPaint = colors[0].paint();

  TextPaint? _textPaint;
  Paint? _sidePaint;
  Paint? _overPaint;
  Paint? _hiddenPaint;

  Cell(int column, int row, int value, {int? reward, Function(Cell)? onInit})
      : super() {
    init(column, row, value, reward: reward, onInit: onInit);
    size = Vector2(1, 1);
  }

  Cell init(int column, int row, int value,
      {int? reward, Function(Cell)? onInit, int hiddenMode = 0}) {
    this.column = column;
    this.row = row;
    this.value = value;
    this.reward = reward ?? 0;
    this.onInit = onInit ?? null;
    this.hiddenMode = hiddenMode;
    state = CellState.Init;

    _sidePaint = colors[value].withAlpha(180).paint();
    _overPaint = colors[value].paint();
    _textPaint = TextPaint(
        config: TextPaintConfig(
            fontSize:
                radius * scales[getScore(value).toString().length.clamp(0, 5)],
            fontFamily: 'quicksand',
            color: hiddenMode > 1 ? colors[value].color : Colors.white));

    if (hiddenMode > 0)
      _hiddenPaint = Paint()
        ..strokeWidth = 2
        ..style = PaintingStyle.stroke
        ..color = hiddenMode > 1 ? colors[value].color : Colors.white;

    size = Vector2(1.3, 1.3);
    addEffect(ScaleEffect(
        size: Vector2(1, 1),
        duration: matched ? 0.2 : 0.3,
        curve: Curves.easeOutBack,
        onComplete: _animationComplete));
    return this;
  }

  void _animationComplete() {
    size = Vector2(1, 1);
    if (state == CellState.Init) state = CellState.Float;
    onInit?.call(this);
    onInit = null;
  }

  void delete(Function(Cell)? onDelete) {
    addEffect(ScaleEffect(
        size: Vector2(0, 0),
        duration: MyGame.random.nextDouble() * 0.8,
        curve: Curves.easeInBack,
        onComplete: () => onDelete?.call(this)));
  }

  @override
  void render(Canvas c) {
    super.render(c);
    if (hiddenMode > 0) {
      c.drawRRect(_overRect.s(size), _hiddenPaint!);
    } else {
      c.drawRRect(_backRect.s(size), _backPaint);
      c.drawRRect(_sideRect.s(size), _sidePaint!);
      c.drawRRect(_overRect.s(size), _overPaint!);
    }

    _textPaint!.render(c, "${hiddenMode == 1 ? "?" : getScore(value)}", _center,
        anchor: Anchor.center);
  }

  @override
  String toString() {
    return "Cell c:$column, r:$row, v:$value, s:$state}";
  }
}

extension RRectExt on RRect {
  RRect s(Vector2 size) {
    if (size.x == 1 && size.y == 1) return this;
    return RRect.fromLTRBXY(left * size.x, top * size.y, right * size.x,
        bottom * size.y, blRadiusX, blRadiusY);
  }
}
