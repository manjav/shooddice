import 'dart:math';
import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flame/gestures.dart';
import 'package:flutter/cupertino.dart';
import 'package:numbers/animate.dart';
import 'package:numbers/core/cell.dart';
import 'package:numbers/core/cells.dart';

class MyGame extends BaseGame with TapDetector {
  @override
  Color backgroundColor() => const Color(0xFF343434);

  @override
  void onAttach() {
    super.onAttach();
  }

  void render(Canvas canvas) {
    super.render(canvas);
  }

  void update(double dt) {
    super.update(dt);
  }

  void onTapDown(TapDownInfo info) {
  }
  }
