import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flutter/cupertino.dart';

class Animate {
  static void tween(PositionComponent target, double duration,
      {double? x,
      double? y,
      double? sizeX,
      double? sizeY,
      double? delay,
      Cubic? curve,
      VoidCallback? onComplete}) {
    x = x ?? target.x;
    y = y ?? target.y;
    sizeX = sizeX ?? target.size.x;
    sizeY = sizeY ?? target.size.y;
    curve = curve ?? Curves.easeInExpo;
    target.addEffect(MoveEffect(
      path: [Vector2(target.x, target.y), Vector2(x, y)],
      curve: curve,
      duration: duration,
      onComplete: onComplete,
    ));
  }
}
