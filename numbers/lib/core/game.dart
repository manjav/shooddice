import 'dart:math';
import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame/game.dart';
import 'package:flame/gestures.dart';
import 'package:flame/palette.dart';
import 'package:flutter/cupertino.dart';
import 'package:numbers/core/cell.dart';
import 'package:numbers/core/cells.dart';

class MyGame extends BaseGame with TapDetector {
  static final padding = 20.0;
  static final Random random = new Random();
  static final colors = [
    PaletteEntry(Color(0xFF2c3134)).paint(),
    PaletteEntry(Color(0xFF23272A)).paint(),
    PaletteEntry(Color(0xFF1F2326)).paint(),
    PaletteEntry(Color(0xFFFF2326)).paint()
  ];
  int _numRewardCells = 0;
  int _numRevives = 0;
  bool isPlaying = false;
  Cell _nextCell = Cell(0, 0, 0);
  Cells _cells = Cells();

  Rect bounds = Rect.fromLTRB(0, 0, 0, 0);
  RRect? _bgRect;
  RRect? _lineRect;
  List<Rect>? _rects;
  Paint _linePaint = colors[0];



  @override
  Color backgroundColor() => colors[0].color;

  @override
  void onAttach() {
    super.onAttach();

    var width = size.x - padding * 2;
    Cell.diameter = width / Cells.width;
    Cell.radius = Cell.diameter * 0.5;
    var height = (Cells.height + 1) * Cell.diameter;
    var t = (size.y - height) * 0.5;
    bounds = Rect.fromLTRB(padding, t, size.x - padding, size.y - t);
    _bgRect = RRect.fromLTRBXY(bounds.left - 4, bounds.top - 4,
        bounds.right + 4, bounds.bottom + 4, 16, 16);
    _lineRect = RRect.fromLTRBXY(bounds.left + 2, bounds.top + Cell.diameter,
        bounds.right - 2, bounds.top + Cell.diameter + 4, 4, 4);
    _rects = List.generate(
        2,
        (i) => Rect.fromLTRB(
            bounds.left + (i + 1) * Cell.diameter,
            _bgRect!.top,
            bounds.right - (i + 1) * Cell.diameter,
            _bgRect!.bottom));

    _nextCell.init(random.nextInt(Cells.width), 0, Cell.getNextValue());
    _nextCell.x = _nextCell.column * Cell.diameter + Cell.radius + bounds.left;
    _nextCell.y = bounds.top + Cell.radius;
    add(_nextCell);

    isPlaying = true;
    _spawn();
  }

  void render(Canvas canvas) {
    canvas.drawRRect(_bgRect!, colors[1]);
    canvas.drawRect(_rects![0], colors[2]);
    canvas.drawRect(_rects![1], colors[1]);
    canvas.drawRRect(_lineRect!, _linePaint);
    super.render(canvas);
  }

  void _spawn() {
    // Check space is clean
    if (_cells.existState(CellState.Float)) return;

    // Check end game
    var row = _cells.length(_nextCell.column);
    if (row >= Cells.height) {
      _linePaint = colors[3];
      isPlaying = false;
      onGameOver?.call();
      // Animate.tween(_endLine, 1.0, {alpha: 0.2}).repeat(1).onComplete(gameOver);
      print("game over!");
      return;
    }

    if (reward > 0) _numRewardCells++;
    var cell = Cell(_nextCell.column, row, _nextCell.value, reward: reward);
    cell.x = bounds.left + cell.column * Cell.diameter + Cell.radius;
    cell.y = _nextCell.y + Cell.diameter - 10;
    _cells.map[cell.column][row] = _cells.last = cell;
    _cells.target =
        bounds.top + Cell.diameter * (Cells.height - row) + Cell.radius;
    add(cell);

    _nextCell.init(_nextCell.column, 0, Cell.getNextValue());

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
    var col = ((info.eventPosition.global.x - bounds.left) / Cell.diameter)
        .clamp(0, Cells.width - 1)
        .floor();
    if (_nextCell.column != col &&
        _cells.last!.state == CellState.Float &&
        !_cells.last!.matched) {
      _nextCell.column = col;

      var _x = bounds.left + _nextCell.column * Cell.diameter + Cell.radius;
      _nextCell.addEffect(MoveEffect(
          duration: 0.3,
          path: [Vector2(_x, _nextCell.y)],
          curve: Curves.easeInOutQuad));

        var row = _cells.length(_nextCell.column);
        if (_cells.last! == _cells.get(_nextCell.column, row - 1)) --row;
        _cells.translate(_cells.last!, _nextCell.column, row);
      _cells.last!.x = _x;
    }
    _fallAll();
  }

  void _fallAll() {
    // var delay = 0.01;
    var time = 0.1;
    _cells.loop((i, j, c) {
      c.state = CellState.Falling;
      var dy =
          bounds.top + Cell.diameter * (Cells.height - c.row) + Cell.radius;
      var coef = ((dy - c.y) / (Cell.diameter * Cells.height)) * 0.2;

      var s1 = CombinedEffect(effects: [
        MoveEffect(
            path: [Vector2(c.x, dy + Cell.radius * coef)], duration: time),
        ScaleEffect(size: Vector2(1, 1 - coef), duration: time)
      ]);
      var s2 = CombinedEffect(effects: [
        MoveEffect(path: [Vector2(c.x, dy)], duration: time),
        ScaleEffect(size: Vector2(1, 1), duration: time)
      ]);
      c.addEffect(SequenceEffect(
          effects: [s1, s2], onComplete: () => fallingComplete(c, dy)));
    }, state: CellState.Float);
  }

  void fallingComplete(Cell cell, double dy) {
    cell.size = Vector2(1, 1);
    cell.y = dy;
    cell.state = CellState.Fell;
    _fell();
  }

  void _fell() {
    // All cells falling completed
    var hasFloat = false;
    _cells.loop((i, j, c) {
      if (c.state.index < CellState.Fell.index) hasFloat = true;
    });
    if (hasFloat) return;
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
        m.addEffect(MoveEffect(
            duration: 0.1, path: [c.position], onComplete: () => remove(m)));
      }

      if (matchs.length > 0) {
        _collectReward(c);
        c.matched = true;
        c.init(c.column, c.row, c.value + matchs.length, onInit: _onCellsInit);
        merges += matchs.length;
  }
      // debugPrint("match $c len:${matchs.length}");
    }
    return merges;
  }

  void _collectReward(Cell cell) {
    if (cell.reward <= 0) return;

    --_numRewardCells;
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

  void _removeCell(int column, int row, bool accumulate) {
    if (_cells.map[column][row] == null) return;
    _cells.map[column][row].delete((c) => remove(c));
    if (accumulate)
      _cells.accumulateColumn(column, row);
    else
      _cells.map[column][row] = null;
  }

  void removeCellsByValueint(value) {
    _cells.loop((i, j, c) => _removeCell(i, j, true), value: value);
  }

  void revive(bool reviveMode) {
    _numRevives++;
    for (var i = 0; i < Cells.width; i++)
      for (var j = Cells.height - 3; j < Cells.height; j++)
        _removeCell(i, j, false);

    Future.delayed(Duration(seconds: 1), null).then((value) {
      isPlaying = true;
      _spawn();
    });
  }
  }
