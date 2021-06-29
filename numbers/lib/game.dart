import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flame/gestures.dart';
import 'package:flame/palette.dart';
import 'package:flutter/cupertino.dart';

class Palette {
  static const PaletteEntry transparent = PaletteEntry(Color(0x00000000));
  static const PaletteEntry red = PaletteEntry(Color(0xFFFF0000));
  static const PaletteEntry blue = PaletteEntry(Color(0xFF0000FF));
  static const PaletteEntry green = PaletteEntry(Color(0xFF00FF00));
}

class MyGame extends BaseGame with MultiTouchDragDetector {
  static int rowsCount = 6;
  static int columnsCount = 4;
  static double gap = 0, padding = 48;
  static double get radius => gap * 0.5;

  Line? _activeLine;
  List<Box>? _boxs;
  Map<int, Dot>? _dots;

  @override
  void onAttach() {
    super.onAttach();
    _dots = Map();
    _boxs = <Box>[];
    var width = size.x - padding * 2;
    gap = width / (columnsCount - 1);
    for (int i = 0; i < columnsCount; i++) {
      for (int j = 0; j < rowsCount; j++) {
        var d = Dot() //addLater
          ..column = i
          ..row = j;
        _dots![i * 100 + j] = d;

        if (i > 0 && j > 0) {
          var b = Box(_dots![(i - 1) * 100 + j - 1]!, _dots![i * 100 + j - 1]!,
              _dots![(i - 1) * 100 + j]!, d);
          _boxs!.add(b);
          add(b);
        }
      }
    }
    _dots!.forEach((i, d) => add(d));
  }

  @override
  Color backgroundColor() => const Color(0x0000000000);

  void onDragStart(int pointerId, Vector2 startPosition) {
    // resumeEngine();
    _dots!.forEach((i, d) {
      if (d.isDragReady(startPosition)) {
        _activeLine = Line();
        _activeLine!.start = d;
        add(_activeLine!);
        return;
      }
    });
  }

  void onDragUpdate(int pointerId, DragUpdateDetails details) {
    if (_activeLine == null) return;
    _activeLine!.end = _activeLine!.start;
    _activeLine!.endPos = details.localPosition - _activeLine!.positionOffset!;

    _dots!.forEach((i, d) {
      if (_activeLine!.isAllowConnct(d)) _activeLine!.end = d;
    });
  }

  void onDragEnd(int pointerId, DragEndDetails details) {
    stopDrag();
  }

  void onDragCancel(int pointerId) {
    stopDrag();
  }

  void stopDrag() {
    // pauseEngine();
    if (_activeLine == null) return;
    if (_activeLine!.isSelfConnect) {
      remove(_activeLine!);
    } else {
      _activeLine!.connectGates();
      checkFillBoxes();
    }
    _activeLine = null;
  }

  void checkFillBoxes() {
    for (var b in _boxs!) b.fill();
  }
}

enum Gate { lock, open, connect }

class Dot extends PositionComponent with HasGameRef<MyGame> {
  final double radius = 20;
  static Paint color = Palette.blue.paint();
  List<Gate> gates = <Gate>[];
  int column = 0, row = 0;
  Offset centre = Offset(0, 0);
  Offset positionOffset = Offset(0, 0);

  @override
  void render(Canvas c) {
    super.render(c);
    c.drawCircle(size.toRect().center, radius, color);
  }

  @override
  void onMount() {
    super.onMount();
    width = height = radius;
    anchor = Anchor.center;
    x = MyGame.gap * column + MyGame.padding;
    y = MyGame.gap * row + MyGame.padding * 2;

    // Create gates
    for (var i = 0; i < 4; i++) gates.add(Gate.lock);
    if (row > 0) gates[0] = Gate.open;
    if (column < MyGame.columnsCount - 1) gates[1] = Gate.open;
    if (row < MyGame.rowsCount - 1) gates[2] = Gate.open;
    if (column > 0) gates[3] = Gate.open;
  }

  @override
  set position(Vector2 position) {
    super.position = position;
    positionOffset = position.toOffset();
  }

  bool isDragReady(Vector2 startPosition) {
    if ((position - startPosition).length > MyGame.radius) return false;
    return gates.any((g) => g == Gate.open);
  }
}

class Line extends PositionComponent with HasGameRef<MyGame> {
  Offset? positionOffset;
  Dot? _start, _end;
  Paint _paint = Palette.blue.paint();
  Offset _startPos = Offset(0, 0), endPos = Offset(0, 0);

  Line() : super() {
    _paint.strokeWidth = 22;
    _paint.strokeCap = StrokeCap.round;
  }

  bool get isSelfConnect => _start == _end;

  Dot get start => _start!;
  set start(Dot dot) {
    _start = dot;
    position = dot.position;
    positionOffset = position.toOffset();
  }

  Dot get end => _end!;
  set end(Dot dot) {
    _end = dot;
    endPos = _end!.position.toOffset() - positionOffset!;
  }

  bool isAllowConnct(Dot end) {
    if (_start == end) return false;
    // Distanse check
    var p = Vector2(endPos.dx + position.x, endPos.dy + position.y);
    if ((end.position - p).length > MyGame.radius) return false;
    // IsFill check
    if (!isFreeGates(start, end)) return false;
    // Neigbour check
    return (start.column == end.column && (start.row - end.row).abs() == 1) ||
        (start.row == end.row && (start.column - end.column).abs() == 1);
  }

  bool isFreeGates(Dot s, Dot e) {
    if (s.column < e.column) return s.gates[1] == Gate.open;
    if (s.column > e.column) return s.gates[3] == Gate.open;
    if (s.row < e.row) return s.gates[2] == Gate.open;
    if (s.row > e.row) return s.gates[0] == Gate.open;
    return false;
  }

  void connectGates() {
    if (isSelfConnect) return;
    if (_start!.column < _end!.column) {
      _start!.gates[1] = Gate.connect;
      _end!.gates[3] = Gate.connect;
    } else if (_start!.column > _end!.column) {
      _start!.gates[3] = Gate.connect;
      _end!.gates[1] = Gate.connect;
    }

    if (_start!.row < _end!.row) {
      _start!.gates[2] = Gate.connect;
      _end!.gates[0] = Gate.connect;
    } else if (_start!.row > _end!.row) {
      _start!.gates[0] = Gate.connect;
      _end!.gates[2] = Gate.connect;
    }
  }

  @override
  void render(Canvas c) {
    super.render(c);
    c.drawLine(_startPos, endPos, _paint);
  }
}

class Box extends PositionComponent with HasGameRef<MyGame> {
  Rect? _rectangle;
  final Dot tl, tr, bl, br;
  Paint _paint = Palette.green.paint();

  bool isFill = false;

  Box(this.tl, this.tr, this.bl, this.br) : super();

  bool fill() {
    if (isFill) return true;
    if (tl.gates[1] == Gate.open || tl.gates[2] == Gate.open) return false;
    if (tr.gates[2] == Gate.open || tr.gates[3] == Gate.open) return false;
    if (bl.gates[0] == Gate.open || bl.gates[1] == Gate.open) return false;
    if (br.gates[0] == Gate.open || br.gates[3] == Gate.open) return false;
    _rectangle = Rect.fromLTRB(tl.x, tl.y, br.x, br.y);
    return isFill = true;
  }

  @override
  void render(Canvas c) {
    super.render(c);
    if (_rectangle != null) c.drawRect(_rectangle!, _paint);
  }
}
