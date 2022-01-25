import 'package:flutter/material.dart';
import 'package:project/utils/utils.dart';

class ChromeDecoration extends BoxDecoration {
  ChromeDecoration({Color? color})
      : super(
            color: color,
            shape: BoxShape.rectangle,
            borderRadius: BorderRadius.all(Radius.circular(24.d)));
}
