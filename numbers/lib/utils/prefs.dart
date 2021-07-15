import 'package:shared_preferences/shared_preferences.dart';

class Prefs {
  static int score = 0;
  static SharedPreferences? _instance;
  static void init(Function onInit) {
    SharedPreferences.getInstance().then((SharedPreferences prefs) {
      _instance = prefs;
      if (!prefs.containsKey("numRuns")) {
        Pref.coin.set(500);
        Pref.removeOne.set(3);
        Pref.removeColor.set(3);
      }
      Pref.numRuns.increase(1);
      onInit();
    });
  }
}

enum Pref { coin, numRuns, rate, record, removeOne, removeColor, isMute }

extension PrefExt on Pref {
  String get name {
    switch (this) {
      case Pref.coin:
        return "coin";
      case Pref.numRuns:
        return "numRuns";
      case Pref.rate:
        return "rate";
      case Pref.record:
        return "record";
      case Pref.removeOne:
        return "removeOne";
      case Pref.removeColor:
        return "removeColor";
      case Pref.isMute:
        return "isMute";
      default:
        return "";
    }
  }

  int get value {
    return Prefs._instance!.getInt(name) ?? 0;
  }

  int set(int value) {
    Prefs._instance!.setInt(name, value);
    return value;
  }

  int increase(int value) {
    return set(this.value + value);
  }
}
