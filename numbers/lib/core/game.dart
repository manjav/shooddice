import 'dart:math';
import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flame/gestures.dart';
import 'package:flutter/cupertino.dart';
import 'package:numbers/animations/animate.dart';
import 'package:numbers/core/cell.dart';
import 'package:numbers/core/cells.dart';

class MyGame extends BaseGame with TapDetector {
  bool isPlaying = false;
  Cell _nextCell = Cell(0, 0, 0, 0);
  Cells _cells = Cells();
  Timer? _timer;

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
    if (_cells.existState(CellState.Float)) return;

    // Check end game
    var row = _cells.length(_nextCell.column);
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
    if (_cells.last == null || _cells.last!.state != CellState.Float) return;

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

      Animate.tween(_nextCell, 0.3,
          x: _nextCell.column * Cell.diameter + Cell.radius,
          curve: Curves.easeInOutQuad);

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
    var delay = 0.01;
    var time = 0.15;
    var numFallings = 0;
    _cells.loop((i, j, c) {
      c.state = CellState.Falling;
      var dy = Cell.diameter * (Cells.height - c.row) + Cell.radius;
      var coef = 0.0;
      Animate.tween(c, time,
          y: dy,
          sizeY: 1 - coef,
          delay: delay,
          onComplete: () => _bounceCell(c));

      ++numFallings;
    }, state: CellState.Flying);

    if (numFallings > 0) {
      _timer = Timer(delay + time + 0.5, callback: _fell);
      _timer!.start();
    }
  }

  void _bounceCell(Cell cell) {
  }

  void _fell() {
    _cells.loop((i, j, c) {
      c.state = CellState.Fell;
    }, state: CellState.Falling);

    // Check all matchs after falling animation
    if (!_findMatchs()) _spawn();
  }

  bool _findMatchs() {
    var numMerges = 0;
    var cp = _nextCell.column;
    var cm = _nextCell.column - 1;
    while (cp < Cells.width || cm > -1) {
      if (cp < Cells.width) {
        numMerges += _fundMatch(cp);
        cp++;
      }
      if (cm > -1) {
        numMerges += _fundMatch(cm);
        cm--;
      }
    }
    return numMerges > 0;
  }

  int _fundMatch(int i) {
    var merges = 0;
    for (var j = 0; j < Cells.height; j++) {
      var c = _cells.map[i][j];
      if (c == null || c.state != CellState.Fell) continue;
      c.state = CellState.Fixed;

      var matchs = _cells.getMatchs(c.column, c.row, c.value);
      // Relaese all cells over matchs
      for (var m in matchs) {
        _cells.accumulateColumn(m.column, m.row);
        _collectReward(m);
        Animate.tween(m, 0.1, x: c.x, y: c.y, onComplete: () => remove(m));
      }

      if (matchs.length > 0) {
        _collectReward(c);
        c.init(c.column, c.row, c.value + matchs.length, onInit: _onCellsInit);
        merges += matchs.length;
  }
      // debugPrint("match $c len:${matchs.length}");
    }
    return merges;
  }
  void _onCellsInit(Cell cell) {

    // More chance for spawm new cells
    if (Cell.spawn_max < 7) {
      var distance = (1.5 * sqrt(Cell.spawn_max)).ceil();
      if (Cell.spawn_max < cell.value - distance)
        Cell.spawn_max = cell.value - distance;
    }

    _fallAll();
  }
  }
