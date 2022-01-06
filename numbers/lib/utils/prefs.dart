import 'package:gameanalytics_sdk/gameanalytics.dart';
import 'package:numbers/core/cell.dart';
import 'package:numbers/dialogs/daily.dart';
import 'package:numbers/utils/analytic.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Prefs {
  static int score = 0;
  static SharedPreferences? _instance;

  static void init(Function onInit) {
    SharedPreferences.getInstance().then((SharedPreferences prefs) async {
      _instance = prefs;
      if (!prefs.containsKey("visitCount")) {
        Pref.coin.set(500, itemType: "game", itemId: "initial");
        Pref.dayFirst.set(DateTime.now().millisecondsSinceEpoch - Days.DAY_LEN);
        Pref.lastBig.set(Cell.firstBigRecord);
        Pref.maxRandom.set(Cell.maxRandomValue);
        Pref.rateTarget.set(2);
        Pref.removeOne.set(3);
        Pref.removeColor.set(3);
      }

      Pref.coinPiggy.set(0);
      Pref.visitCount.increase(1);
      onInit();
    });
  }

  static void setString(String key, String value) {
    _instance!.setString(key, value);
  }

  static String getString(String key) {
    return _instance!.getString(key) ?? "";
  }

  static int getInt(String key) {
    return _instance!.getInt(key) ?? 0;
  }

  static void setInt(String key, int value, bool backup) {
    _instance!.setInt(key, value);
    // if (backup) _backup();
  }

  static int getBig(int value) => _instance!.getInt("big_$value") ?? 0;
  static void increaseBig(int value) {
    var key = "big_$value";
    setInt(key, getInt(key) + 1, true);
  }
}

enum Pref {
  coin,
  coinPiggy,
  dayCount,
  dayFirst,
  isMute,
  isVibrateOff,
  noAds,
  lastBig,
  maxRandom,
  numRevives,
  playCount,
  rate,
  ratedBefore,
  rateTarget,
  record,
  removeOne,
  removeColor,
  score,
  tutorMode,
  visitCount
}

extension PrefExt on Pref {
  String get name {
    switch (this) {
      case Pref.coin:
        return "coin";
      case Pref.coinPiggy:
        return "coinPiggy";
      case Pref.dayFirst:
        return "dayFirst";
      case Pref.dayCount:
        return "dayCount";
      case Pref.isMute:
        return "isMute";
      case Pref.isVibrateOff:
        return "isVibrateOff";
      case Pref.lastBig:
        return "lastBig";
      case Pref.maxRandom:
        return "maxRandom";
      case Pref.numRevives:
        return "numRevives";
      case Pref.noAds:
        return "noAds";
      case Pref.playCount:
        return "playCount";
      case Pref.rateTarget:
        return "rateTarget";
      case Pref.rate:
        return "rate";
      case Pref.ratedBefore:
        return "ratedBefore";
      case Pref.record:
        return "record";
      case Pref.removeOne:
        return "removeOne";
      case Pref.removeColor:
        return "removeColor";
      case Pref.score:
        return "score";
      case Pref.tutorMode:
        return "tutorMode";
      case Pref.visitCount:
        return "visitCount";
    }
  }

  int get value {
    return Prefs.getInt(name);
  }

  int set(int value, {bool backup = true, String? itemType, String? itemId}) {
    if (this == Pref.coin) {
      var type = value > this.value
          ? GAResourceFlowType.Source
          : GAResourceFlowType.Sink;
      Analytics.resource(type, name, value.abs(), itemType!, itemId!);
    }
    Prefs.setInt(name, value, backup);
    return value;
  }

  int increase(int value,
      {bool backup = true, String? itemType, String? itemId}) {
    if (value == 0) return 0;
    return set(this.value + value,
        backup: backup, itemType: itemType, itemId: itemId);
  }
}
