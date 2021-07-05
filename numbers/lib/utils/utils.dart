import 'package:intl/intl.dart';

class Utils {}

extension IntExt on int {
  static final _formatter = NumberFormat('#,##,###');
  String format() {
    return _formatter.format(this);
  }
}
