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

}
