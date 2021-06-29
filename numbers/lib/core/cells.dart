import 'package:flutter/foundation.dart';
import 'package:numbers/core/cell.dart';

class Cells {
  static final width = 5;
  static final height = 6;

  Cell? last;
  double? target;
  List<List> map = List.generate(
      width, (c) => List.generate(height, (r) => null, growable: false),
      growable: false);
  void add(Cell cell) {
    map[cell.column][cell.row] = cell;
    last = cell;
    target = Cell.diameter * (height - cell.row) + Cell.radius;
  }

  Cell? get(int column, int row) {
    if (column < 0 || column >= width || row < 0 || row >= height) return null;
    return map[column][row];
  }

  void loop(Function(int, int, Cell) callback, {CellState? state}) {
    for (var i = 0; i < width; i++) {
      for (var j = 0; j < height; j++) {
        var c = get(i, j);
        if (c != null && (state == null || state == c.state))
          callback.call(i, j, map[i][j]);
      }
    }
  }

  bool existState(CellState state) {
    for (var i = 0; i < width; i++)
      for (var j = 0; j < height; j++)
        if (map[i][j] != null && map[i][j].state == state) return true;
    return false;
  }

  int length(int column) {
    var len = 0;
    for (var r = 0; r < height; r++) {
      if (get(column, r) == null) break;
      ++len;
    }
    return len;
  }

  void translate(Cell c, int column, int row) {
    debugPrint(" => $c $column $row");
    map[c.column][c.row] = null;
    c.column = column;
    c.row = row;
    map[column][row] = c;
  }

  List<Cell> getMatchs(int column, int row, int value) {
    var matchs = <Cell>[];
    _addMatch(column, row + 1, value, matchs); // top
    _addMatch(column, row - 1, value, matchs); // bottom
    _addMatch(column - 1, row, value, matchs); // left
    _addMatch(column + 1, row, value, matchs); // right
    // print(c, matchs);
    return matchs;
  }

  void _addMatch(int column, int row, int value, List<Cell> matchs) {
    var cell = get(column, row);
    // print("_addMatch", column, row, cell);
    if (cell != null && cell.value == value) matchs.add(cell);
  }

  bool accumulateColumn(int column, int row) {
    var found = false;
    map[column][row] = null;
    for (var r = row + 1; r < height; r++) {
      var c = map[column][r];
      if (c == null) continue;
      // print("acc", c);
      map[c.column][c.row] = null;
      --c.row;
      c.state = CellState.Flying;
      map[c.column][c.row] = c;
      found = true;
    }
    return found;
  }
}
