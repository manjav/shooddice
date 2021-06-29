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
  Cell _nextCell = Cell(0, 0, 0, 0);
  Cells _cells = Cells();
  @override
  Color backgroundColor() => const Color(0xFF343434);

  @override
  void onAttach() {
    super.onAttach();
    _nextCell.init(random.nextInt(Cells.width), 0, Cell.getNextValue(), 0);
    _nextCell.x = _nextCell.column * Cell.diameter + Cell.radius;
    _nextCell.y = 0;
    add(_nextCell);

    isPlaying = true;
    _spawn();
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
