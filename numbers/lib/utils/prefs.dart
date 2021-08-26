import 'package:flutter/cupertino.dart';
import 'package:numbers/utils/gemeservice.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Prefs {
  static int score = 0;
  static SharedPreferences? _instance;
  static void init(Function onInit) {
    SharedPreferences.getInstance().then((SharedPreferences prefs) {
      _instance = prefs;
      _initPlayService();
      if (!prefs.containsKey("visitCount")) {
        Pref.noAds.set(0);
        Pref.coin.set(500);
        Pref.removeOne.set(3);
        Pref.removeColor.set(3);
        Pref.rateTarget.set(5);
      }
      Pref.visitCount.increase(1);
      onInit();
    });
  }

  static void _set(String key, int value, bool backup) {
    _instance!.setInt(key, value);
    if (backup) _backup();
  }

  static int getBig(int value) => _instance!.getInt("big_$value") ?? 0;
  static void increaseBig(int value) {
    var key = "big_$value";
    if (_instance!.containsKey(key))
      _set(key, _instance!.getInt(key)! + 1, true);
    else
      _set(key, 1, true);
  }

  static Future<bool> _backup() async {
    return false;
  }

  static _initPlayService() async {
    SigninResult result = await PlayGames.signIn(scopeSnapshot: true);
    if (result.success) {
      // await PlayGames.setPopupOptions();
      debugPrint("======${result.account!.displayName} ${result.account!.email}");
    } else {
      debugPrint(result.message);
    }
  }
}

enum Pref {
  coin,
  isMute,
  isVibrateOff,
  noAds,
  playCount,
  rate,
  ratedBefore,
  rateTarget,
  record,
  removeOne,
  removeColor,
  tutorMode,
  visitCount
}

extension PrefExt on Pref {
  String get name {
    switch (this) {
      case Pref.coin:
        return "coin";
      case Pref.isMute:
        return "isMute";
      case Pref.isVibrateOff:
        return "isVibrateOff";
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
      case Pref.tutorMode:
        return "tutorMode";
      case Pref.visitCount:
        return "visitCount";
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
