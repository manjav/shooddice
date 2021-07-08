import 'dart:math';
import 'dart:ui' as ui;

import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame/game.dart';
import 'package:flame/gestures.dart';
import 'package:flutter/cupertino.dart';
import 'package:numbers/core/achieves.dart';
import 'package:numbers/core/cell.dart';
import 'package:numbers/core/cells.dart';
import 'package:numbers/utils/prefs.dart';
import 'package:numbers/utils/sounds.dart';
import 'package:numbers/utils/themes.dart';

enum GameEvent { big, lose, record, score }

class MyGame extends BaseGame with TapDetector {
  static final padding = 20.0;
  static final Random random = new Random();

  Function(GameEvent, int)? onGameEvent;
  bool isPlaying = false;
  int numRevives = 0;
  Rect bounds = Rect.fromLTRB(0, 0, 0, 0);
  bool boostNext = false;
  bool boostBig = false;

  bool _recordChanged = false;
  int _numRewardCells = 0;
  int _mergesCount = 0;
  int _valueRecord = 0;
  Cell _nextCell = Cell(0, 0, 0);
  Cells _cells = Cells();

  RRect? _bgRect;
  RRect? _lineRect;
  List<Rect>? _rects;
  Paint _linePaint = Paint();
  Paint _mainPaint = Paint()..color = Themes.swatch[TColors.black]![2];
  Paint _zebraPaint = Paint()..color = Themes.swatch[TColors.black]![3];
  FallingEffect? _fallingEffect;

  MyGame({this.onGameEvent}) : super() {
    Prefs.score = 0;
  }
  @override
  Color backgroundColor() => Themes.swatch[TColors.black]![0];

  void _addScore(int value) {
    var _new = Prefs.score += Cell.getScore(value);
    onGameEvent?.call(GameEvent.score, _new);
    if (Pref.record.value >= Prefs.score) return;
    Pref.record.set(Prefs.score);
    if (Prefs.score > Cell.firstRecord && !_recordChanged) {
      isPlaying = false;
      onGameEvent?.call(GameEvent.record, Prefs.score);
      _recordChanged = true;
    }
  }

  @override
  void onAttach() {
    super.onAttach();

    _linePaint.color = Themes.swatch[TColors.black]![0];
    var width = size.x - padding * 2;
    Cell.diameter = width / Cells.width;
    Cell.radius = Cell.diameter * 0.5;
    var height = (Cells.height + 1) * Cell.diameter;
    var t = (size.y - height) - 100;
    bounds = Rect.fromLTRB(padding, t, size.x - padding, t + Cell.diameter * 7);
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

    add(_fallingEffect = FallingEffect());

    _valueRecord = Cell.firstBigRecord;
    _nextCell.init(random.nextInt(Cells.width), 0, Cell.getNextValue());
    _nextCell.x = _nextCell.column * Cell.diameter + Cell.radius + bounds.left;
    _nextCell.y = bounds.top + Cell.radius;
    add(_nextCell);

    // Add initial cells
    if (boostBig) _createCell(_nextCell.column, 9);
    var cols = List.generate(5, (i) => random.nextInt(Cells.width));
    for (var c in cols) _createCell(c, Cell.getNextValue());

    isPlaying = true;
    _fallAll();
  }

  void _createCell(int column, value) {
    var row = _cells.length(column);
    while (_cells.getMatchs(column, row, value).length > 0)
      value = Cell.getNextValue();
    var cell = Cell(column, row, value);
    cell.x = bounds.left + column * Cell.diameter + Cell.radius;
    cell.y = bounds.top + Cell.diameter * (Cells.height - row) + Cell.radius;
    cell.state = CellState.Float;
    _cells.map[column][row] = cell;
    add(cell);
  }

  void render(Canvas canvas) {
    canvas.drawRRect(_bgRect!, _mainPaint);
    canvas.drawRect(_rects![0], _zebraPaint);
    canvas.drawRect(_rects![1], _mainPaint);
    canvas.drawRRect(_lineRect!, _linePaint);
    super.render(canvas);
  }

  void _spawn() {
    // Check space is clean
    if (_cells.existState(CellState.Float)) return;

    // Check end game
    var row = _cells.length(_nextCell.column);
    if (row >= Cells.height) {
      _linePaint.color = Themes.swatch[TColors.orange]![0];
      isPlaying = false;
      onGameEvent?.call(GameEvent.lose, 0);
      debugPrint("game over!");
      return;
    }

    var reward = _numRewardCells > 0 || random.nextDouble() > 0.05
        ? 0
        : random.nextInt(_nextCell.value * 10);
    if (reward > 0) _numRewardCells++;
    var cell = Cell(_nextCell.column, row, _nextCell.value, reward: reward);
    cell.x = bounds.left + cell.column * Cell.diameter + Cell.radius;
    cell.y = _nextCell.y + Cell.diameter - 20;
    _cells.map[cell.column][row] = _cells.last = cell;
    _cells.target =
        bounds.top + Cell.diameter * (Cells.height - row) + Cell.radius;
    add(cell);
    _mergesCount = 0;
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
    if (_cells.last!.state == CellState.Float && !_cells.last!.matched) {
      var col = ((info.eventPosition.global.x - bounds.left) / Cell.diameter)
          .clamp(0, Cells.width - 1)
          .floor();
      var row = _cells.length(col);
      if (_cells.last! == _cells.get(col, row - 1)) --row;
      var _y = bounds.top + Cell.diameter * (Cells.height - row) + Cell.radius;
      if (_cells.last!.y > _y) {
        debugPrint("col:$col  ${_cells.last!.y}  >>> $_y");
        return;
      }
      var _x = bounds.left + col * Cell.diameter + Cell.radius;
      // Change column
      if (_nextCell.column != col) {
        _nextCell.column = col;
        _nextCell.addEffect(MoveEffect(
            duration: 0.3,
            path: [Vector2(_x, _nextCell.y)],
            curve: Curves.easeInOutQuad));

        _cells.translate(_cells.last!, col, row);
        _cells.last!.x = _x;
      }

      Sound.play("fall");
      _fallingEffect!.tint(
          Rect.fromLTRB(_x - Cell.radius, _cells.last!.y + Cell.diameter,
              _x + Cell.radius, bounds.bottom),
          Cell.colors[_cells.last!.value].color);
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
        add(Score(Cell.getScore(c.value), c.x, c.y - 20));
        merges += matchs.length;
      }
      // debugPrint("match $c len:${matchs.length}");
    }
    if (merges > 0) {
      _mergesCount++;
      Sound.play("merge-$_mergesCount");
    }
    return merges;
  }

  void _collectReward(Cell cell) {
    if (cell.reward <= 0) return;

    --_numRewardCells;
  }

  void _onCellsInit(Cell cell) {
    _addScore(cell.value);

    // Show big number popup
    if (cell.value > _valueRecord) {
      isPlaying = false;
      onGameEvent?.call(GameEvent.big, _valueRecord = cell.value);
    }

    // More chance for spawm new cells
    if (Cell.maxRandomValue < 7) {
      var distance = (1.5 * sqrt(Cell.maxRandomValue)).ceil();
      if (Cell.maxRandomValue < cell.value - distance)
        Cell.maxRandomValue = cell.value - distance;
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

  void revive() {
    _linePaint.color = Themes.swatch[TColors.black]![0];
    numRevives++;
    for (var i = 0; i < Cells.width; i++)
      for (var j = Cells.height - 3; j < Cells.height; j++)
        _removeCell(i, j, false);

    Future.delayed(Duration(seconds: 1), null).then((value) {
      isPlaying = true;
      _spawn();
    });
  }
}

class FallingEffect extends PositionComponent with HasGameRef<MyGame> {
  Rect? _rect;
  Color? _color;
  int _alpha = 0;

  void tint(Rect rect, Color color) {
    _rect = rect;
    _color = color;
    _alpha = 255;
  }

  void render(Canvas canvas) {
    if (_alpha <= 0) return;
    canvas.drawRect(_rect!, alphaPaint(_alpha));
    _alpha -= 15;
    super.render(canvas);
  }

  Paint alphaPaint(int alpha) {
    return Paint()
      ..shader = ui.Gradient.linear(_rect!.topCenter, _rect!.bottomCenter, [
        _color!.withAlpha(0),
        _color!.withAlpha(_alpha),
      ]);
  }
}
