import 'package:flutter/services.dart';
import 'package:numbers/utils/prefs.dart';
import 'package:soundpool/soundpool.dart';

class Sound {
  static Map<String, int> map = Map();
  static Soundpool pool = Soundpool.fromOptions();
  static Future<void> init() async {
    for (var i = 1; i <= 9; i++) add("merge-$i");
    add("fall");
    add("lose");
    add("pop");
    add("tap");
    add("win");
  }

  static Future<void> add(String name) async {
    int soundId =
        await rootBundle.load("assets/sounds/$name.ogg").then((soundData) {
      return pool.load(soundData);
    });
    map[name] = soundId;
  }

  static Future<int> play(String name) async {
    if (Pref.isMute.value == 1) return 0;
    if (map.isEmpty) return 0;
    return await pool.play(map[name]!);
  }
}
