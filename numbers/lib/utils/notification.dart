import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
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
  }

  static Future<dynamic> onDidReceiveLocalNotification(
      int? id, String? title, String? body, String? payload) async {
    debugPrint("title $title body $body payload: $payload");
  }

  static Future<dynamic> onSelectNotification(String? payload) async {
    if (payload != null) {
      debugPrint('notification payload: $payload');
    }
  }
}
