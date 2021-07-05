import 'package:flutter/services.dart';
import 'package:soundpool/soundpool.dart';

class Sound {
  static Map<String, int> map = Map();
  static Soundpool pool = Soundpool.fromOptions();
  static Future<void> init() async {
    for (var i = 1; i <= 9; i++) add("merge-$i");
    add("fall");
    add("lose");
  }

  static Future<void> add(String name) async {
    int soundId =
        await rootBundle.load("assets/sounds/$name.ogg").then((soundData) {
      return pool.load(soundData);
    });
    map[name] = soundId;
  }

  static Future<int> play(String name) async {
    return await pool.play(map[name]!);
  }
}
