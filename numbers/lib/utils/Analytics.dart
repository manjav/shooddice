import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_analytics/observer.dart';
import 'package:gameanalytics_sdk/gameanalytics.dart';
import 'dart:async';

class Analytics {
  static late FirebaseAnalytics _firebaseAnalytics;
  static late FirebaseAnalyticsObserver _observer;

  static Future<void> init(
      FirebaseAnalytics analytics, FirebaseAnalyticsObserver observer) async {
    _firebaseAnalytics = analytics;
    _observer = observer;

    GameAnalytics.setEnabledInfoLog(false);
    GameAnalytics.setEnabledVerboseLog(false);

    // GameAnalytics.configureAvailableCustomDimensions01(["ninja", "samurai"]);
    // GameAnalytics.configureAvailableCustomDimensions02(["whale", "dolphin"]);
    // GameAnalytics.configureAvailableCustomDimensions03(["horde", "alliance"]);
    GameAnalytics.configureAvailableResourceCurrencies(["coin"]);
    GameAnalytics.configureAvailableResourceItemTypes(
        ["game", "confirm", "shop", "start"]);

    GameAnalytics.configureAutoDetectAppVersion(true);
    GameAnalytics.initialize("2c9380c96ef57f01f353906b341a21cc",
        "275843fe2b762882e938a16d6b095d7661670ee9");
  }

  }
