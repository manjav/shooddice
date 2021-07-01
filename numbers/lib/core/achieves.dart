import 'package:flame/components.dart';
import 'package:flutter/cupertino.dart';
import 'package:numbers/core/game.dart';

class Score extends PositionComponent with HasGameRef<MyGame> {
  static final _textColor = Color(0xFFFFFFFF);

  final value;
  int _alpha = 255;
  double dy = 0;
  double diff = 100;
  Score(this.value, double x, double y) {
    position = Vector2(x, y);
    dy = y - diff;
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    if (_alpha <= 5) {
      remove();
      return;
    }
    var change = (dy - y);
    _alpha = (change / diff * -255).floor();
    y += change / 50;
    TextPaint(
            config: TextPaintConfig(
                fontSize: 32,
                fontFamily: 'quicksand',
                color: _textColor.withAlpha(_alpha)))
        .render(canvas, "+$value", Vector2.zero(), anchor: Anchor.center);
  }
}
