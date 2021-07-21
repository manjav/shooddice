import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class Notifier {
  static void init() async {
    FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
        FlutterLocalNotificationsPlugin();
    // initialise the plugin. app_icon needs to be a added as a drawable resource to the Android head project
    AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('app_icon');
    final IOSInitializationSettings initializationSettingsIOS =
        IOSInitializationSettings(
            onDidReceiveLocalNotification: onDidReceiveLocalNotification);
    final InitializationSettings initializationSettings =
        InitializationSettings(
            android: initializationSettingsAndroid,
            iOS: initializationSettingsIOS);

    await flutterLocalNotificationsPlugin.initialize(initializationSettings,
        onSelectNotification: onSelectNotification);
    tz.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation("Asia/Tehran"));

    var title = "MergeNums";
    var body = "You are really awesome!";
    var times = [1, 3, 7];
    await flutterLocalNotificationsPlugin.cancelAll();
    for (var i = 0; i < times.length; i++) {
      await flutterLocalNotificationsPlugin.zonedSchedule(
          i,
          title,
          body,
          tz.TZDateTime.now(tz.local)
              .add(Duration(seconds: times[i] * 24 * 3600)),
          const NotificationDetails(
              android: AndroidNotificationDetails('your channel id',
                  'your channel name', 'your channel description')),
          androidAllowWhileIdle: true,
          uiLocalNotificationDateInterpretation:
              UILocalNotificationDateInterpretation.absoluteTime);
    }
  }

  static Future<dynamic> onDidReceiveLocalNotification(
      int? id, String? title, String? body, String? payload) async {
    debugPrint("=============  title $title body $body payload: $payload");
  }

  static Future<dynamic> onSelectNotification(String? payload) async {
    if (payload != null) {
      debugPrint('("============= notification payload: $payload');
    }
  }
}
