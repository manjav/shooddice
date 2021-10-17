import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';

extension Localization on String {
  static bool isRTL = false;
  static String languageCode = "en";
  static Map<String, dynamic>? _sentences;
  static TextDirection dir = TextDirection.ltr;

  static Future<void> init() async {
    dir = isRTL ? TextDirection.rtl : TextDirection.ltr;
    var data = await rootBundle.loadString('texts/locale.json');
    var _result = json.decode(data);
    _sentences = Map();
    _result.forEach((String key, dynamic value) {
      _sentences![key] = value.toString();
    });
  }

  String l([List<String>? args]) {
    final key = this;
    if (_sentences == null) throw "[Localization System] sentences = null";
    var result = _sentences![key];
    if (result == null) return key;
    if (args != null) {
      args.forEach((arg) {
        result = result!.replaceFirst(RegExp(r'%s'), arg.toString());
      });
    }
    return result;
  }
}