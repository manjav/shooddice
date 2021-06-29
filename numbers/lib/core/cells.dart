import 'package:numbers/core/cell.dart';

class Cells {
  static final width = 5;
  static final height = 6;

  List<List> map = List.generate(
      width, (c) => List.generate(height, (r) => null, growable: false),
      growable: false);
  void add(Cell cell) {
    map[cell.column][cell.row] = cell;
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
}
