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

  void _spawn() {
    // Check space is clean
    if (_cells.existState(CellState.Flying)) return;
    var reward = 0;
    if (reward > 0) _numRewardCells++;
    var cell = Cell(_nextCell.column, row, _nextCell.value, reward);
    cell.x = cell.column * Cell.diameter + Cell.radius;
    cell.y = _nextCell.y;
    _cells.add(cell);
    add(cell);

    _nextCell.init(_nextCell.column, 0, Cell.getNextValue(), 0);

  }

  void update(double dt) {
    super.update(dt);
    if (!isPlaying) return;
    if (_cells.last == null || _cells.last!.state != CellState.Flying) return;

    // Check reach to target
    if (_cells.last!.y < _cells.target!) {
      _cells.last!.y += Cell.speed;
      return;
    }

    // Change cell state
    _fallAll();
  }

  void onTapDown(TapDownInfo info) {

    if (!isPlaying) return;
    var col = (info.eventPosition.global.x / Cell.diameter)
        .clamp(0, Cells.width - 1)
        .floor();
    if (_nextCell.column != col) {
      print("${_nextCell.column} changed to $col");
      _nextCell.column = col;

      if (_cells.last!.state == CellState.Flying) {
        var row = _cells.length(_nextCell.column);
        if (_cells.last! == _cells.get(_nextCell.column, row - 1)) --row;
        _cells.translate(_cells.last!, _nextCell.column, row);
        _cells.last!.x = _cells.last!.column * Cell.diameter + Cell.radius;
      }
    }
    _fallAll();
  }

  void _fallAll() {
    var numFallings = 0;
    _cells.loop((i, j, c) {
      c.state = CellState.Falling;
      c.y = Cell.diameter * (Cells.height - c.row) + Cell.radius;
      ++numFallings;
    }, state: CellState.Flying);

    if (numFallings > 0) {
      _fell();
    }
  }


  void _fell() {
    _cells.loop((i, j, c) {
      c.state = CellState.Fell;
    }, state: CellState.Falling);

    _spawn();
  }
  }
  }
