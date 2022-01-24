import 'dart:ui' as ui;

import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame_svg/svg.dart';
import 'package:flutter/material.dart';
import 'package:project/animations/animate.dart';
import 'package:project/core/cells.dart';
import 'package:project/core/game.dart';
import 'package:project/utils/prefs.dart';
import 'package:project/utils/utils.dart';

enum CellState { init, float, falling, fell, fixed }

class Cell extends PositionComponent {
  static int lastRandomValue = 9;
  static int maxRandom = 0;
  static const firstBigRecord = 8;
  static const maxRandomValue = 4;
  static const sideColors = <Color>[
    Color(0xFF191C1D),
    Color(0xFF7E03CB),
    Color(0xFFB8374B),
    Color(0xFFE9682A),
    Color(0xFF2CA7CA),
    Color(0xFF4B84DA),
    Color(0xFF8C1EB2),
    Color(0xFF48BE2A),
    Color(0xFFD44881),
    Color(0xFFDF382D),
    Color(0xFF99B42E),
    Color(0xFF80514B),
    Color(0xFF8F3C6E),
    Color(0xFF8F7633),
    Color(0xFFE29C5A),
    Color(0xFF203793),
    Color(0xFF326B7A),
    Color(0xFF2D3B55)
  ];
  static const colors = [
    <Color>[Color(0xFF191C1D), Color(0xFF191C1D)],
    <Color>[Color(0xFFE85CFF), Color(0xFF9A00FE)],
    <Color>[Color(0xFFFF7676), Color(0xFFE52956)],
    <Color>[Color(0xFFFFEC42), Color(0xFFFF842B)],
    <Color>[Color(0xFF3AFF95), Color(0xFF15D3D3)],
    <Color>[Color(0xFF7BD7FF), Color(0xFF1DADFF)],
    <Color>[Color(0xFFE167A2), Color(0xFFA520C6)],
    <Color>[Color(0xFFECFF76), Color(0xFF29E55D)],
    <Color>[Color(0xFFFF86A3), Color(0xFFFF2B91)],
    <Color>[Color(0xFFFF9E58), Color(0xFFFF5631)],
    <Color>[Color(0xFFFCFF6E), Color(0xFFB2D81C)],
    <Color>[Color(0xFFE59494), Color(0xFF9F6159)],
    <Color>[Color(0xFFE98AB7), Color(0xFFB04C8E)],
    <Color>[Color(0xFFF2CE71), Color(0xFFA18B51)],
    <Color>[Color(0xFFFFE7AA), Color(0xFFFFD231)],
    <Color>[Color(0xFF3988FF), Color(0xFF1332CB)],
    <Color>[Color(0xFF9CC9E2), Color(0xFF2D899D)],
    <Color>[Color(0xFF7A95BD), Color(0xFF374C74)]
  ];

  static double diameter = 64.0;
  static double padding = 1.8;
  static double roundness = 16.0;
  static double thickness = 2.0;
  static double get radius => diameter * 0.5;
  static double get strock => padding * 1.5;
  static double getX(int col) => MyGame.bounds.left + col * diameter + radius;
  static double getY(int row) => MyGame.bounds.top + row * diameter + radius;
  static int getScore(int value) => value;
  // static int getNextValue(int step) => [1, 2, 3, 3, 2, 2, 1, 1][step];
  // static int getNextColumn(int step) => [0, 1, 1, 2, 4, 4, 4, 4][step];
  static int getNextValue(int seed) {
    if (Pref.tutorMode.value == 0) return [1, 3, 5, 1, 2, 4, 5][seed];
    var min = seed.min(1).max((maxRandom * 0.4).ceil());
    return min + MyGame.random.nextInt(maxRandom - min);
  }

  static int getNextColumn(int seed) => Pref.tutorMode.value == 0
      ? [2, 0, 3, 2, 1, 1, 2][seed]
      : MyGame.random.nextInt(Cells.width);

  bool matched = false;
  int hiddenMode = 0;
  int column = 0, row = 0, reward = 0, value = 0;
  Function(Cell)? onInit;
  CellState state = CellState.init;
  // static RRect _backRect = RRect.fromLTRBXY(
  //     padding - radius,
  //     padding - radius,
  //     radius - padding,
  //     radius - padding,
  //     roundness * 1.3,
  //     roundness * 1.3);
  static final RRect _sideRect = RRect.fromLTRBXY(
      padding - radius,
      padding - radius,
      radius - padding,
      radius - padding + thickness,
      roundness,
      roundness);
  static final RRect _overRect = RRect.fromLTRBXY(
      strock - radius,
      strock - radius,
      radius - strock,
      radius - strock - thickness * 2,
      roundness * 0.7,
      roundness * 0.7);

  Paint? _sidePaint;
  Paint? _overPaint;
  Paint? _hiddenPaint;
  Svg? _valuePaint;
  Svg? _rewardPaint;
  final Vector2 _valuePos = Vector2(-16, -18);
  final Vector2 _valueSize = Vector2.all(32);
  final Vector2 _rewardPos = Vector2.all(-radius * 0.86);
  final Vector2 _rewardSize = Vector2.all(26);

  Cell(int column, int row, int value, {int reward = 0, Function(Cell)? onInit})
      : super() {
    init(column, row, value, reward: reward, onInit: onInit);
    size = Vector2(1, 1);
  }

  Future<Cell> init(int column, int row, int value,
      {int reward = 0, Function(Cell)? onInit, int hiddenMode = 0}) async {
    this.column = column;
    this.row = row;
    this.value = value;
    this.reward = reward;
    this.onInit = onInit;
    this.hiddenMode = hiddenMode;
    state = CellState.init;
    _sidePaint = Paint()..color = sideColors[value];
    _overPaint = Paint()
      ..shader = ui.Gradient.radial(
          Offset(-radius * 0.15, -radius * 0.4), radius, colors[value]);

    var shadows = <Shadow>[];
    if (hiddenMode == 0) {
      shadows.add(BoxShadow(
          color: Colors.black.withAlpha(150),
          blurRadius: 3,
          offset: Offset(0, radius * 0.05)));
    }

    _valuePaint = await Svg.load('images/n$value.svg');

    if (hiddenMode > 0) {
      _hiddenPaint = Paint()
        ..strokeWidth = 2
        ..style = PaintingStyle.stroke
        ..color = hiddenMode > 1 ? colors[value][1] : Colors.white;
    }
    if (reward > 0) _rewardPaint = await Svg.load('images/coin.svg');

    size = Vector2(1.3, 1.3);
    var controller = EffectController(
        duration: matched ? 0.2 : 0.3, curve: Curves.easeOutBack);
    add(SizeEffect.to(Vector2(1, 1), controller));
    Animate.checkCompletion(controller, _animationComplete);
    return this;
  }

  void _animationComplete() {
    size = Vector2(1, 1);
    if (state == CellState.init) state = CellState.float;
    onInit?.call(this);
    onInit = null;
  }

  void delete(Function(Cell)? onDelete) {
    var controller = EffectController(
        duration: MyGame.random.nextDouble() * 0.8, curve: Curves.easeInBack);
    add(SizeEffect.to(Vector2.zero(), controller));
    Animate.checkCompletion(controller, () => onDelete?.call(this));
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    if (_sidePaint == null) return;
    if (hiddenMode > 0) {
      canvas.drawRRect(_overRect.s(size), _hiddenPaint!);
    } else {
      // canvas.drawRRect(_backRect.s(size), _backPaint);
      canvas.drawRRect(_sideRect.s(size), _sidePaint!);
      canvas.drawRRect(_overRect.s(size), _overPaint!);
    }

    _valuePaint!.renderPosition(canvas, _valuePos, _valueSize);
    if (reward > 0)
      _rewardPaint!.renderPosition(canvas, _rewardPos, _rewardSize);
  }

  @override
  String toString() => "Cell c:$column, r:$row, v:$value, s:$state}";

  static void updateSizes(double _diameter) {
    diameter = _diameter;
    padding = _diameter * 0.04;
    roundness = _diameter * 0.15;
    thickness = _diameter * 0.02;
  }
}

extension RRectExt on RRect {
  RRect s(Vector2 size) {
    if (size.x == 1 && size.y == 1) return this;
    return RRect.fromLTRBXY(left * size.x, top * size.y, right * size.x,
        bottom * size.y, blRadiusX * size.x, blRadiusY * size.y);
  }
}
