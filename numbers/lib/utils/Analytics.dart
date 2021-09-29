import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_analytics/observer.dart';

class Analytics {
  static late FirebaseAnalytics _firebaseAnalytics;
  static late FirebaseAnalyticsObserver _observer;


  static void init(
      FirebaseAnalytics analytics, FirebaseAnalyticsObserver observer) {
    _firebaseAnalytics = analytics;
    _observer = observer;
  }
