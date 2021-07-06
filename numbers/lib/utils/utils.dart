import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';

class Utils {}

extension IntExt on int {
  static final _formatter = NumberFormat('#,##,###');
  String format() {
    return _formatter.format(this);
  }
}

class SVG {
  static SvgPicture show(String name, double size) {
    return SvgPicture.asset("assets/images/$name.svg", width: size);
  }
}
