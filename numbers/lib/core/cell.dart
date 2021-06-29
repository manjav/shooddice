import 'dart:math';

import 'package:flame/components.dart';
import 'package:flame/palette.dart';
import 'package:flutter/painting.dart';
import 'package:numbers/core/game.dart';

enum CellState { Init, Flying, Falling, Fell, Fixed }

class Cell extends PositionComponent with HasGameRef<MyGame> {
  static final speed = 0.8;
  static final diameter = 64.0;
  static final radius = diameter * 0.5;
  static final border = 2.0;
  static final round = 7.0;

  Cell(int column, int row, int value, int reward) : super() {
    init(column, row, value, reward);
  }

  Cell init(int column, int row, int value, int reward) {
    this.column = column;
    this.row = row;
    this.value = value;
    this.reward = reward;
    state = CellState.Init;

    return this;
    this.state = CellState.Flying;
  }

  @override
  void render(Canvas c) {
    super.render(c);
  }

  @override
  String toString() {
    return "Cell c:$column, r:$row, v:$value, s:$state}";
  }
  }
