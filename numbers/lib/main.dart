import 'package:device_info/device_info.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_analytics/observer.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:in_app_purchase_android/in_app_purchase_android.dart';
import 'package:numbers/dialogs/quit.dart';
import 'package:numbers/utils/ads.dart';
import 'package:numbers/utils/analytic.dart';
import 'package:numbers/utils/localization.dart';
import 'package:numbers/utils/notification.dart';
import 'package:numbers/utils/prefs.dart';
import 'package:numbers/utils/sounds.dart';
import 'package:numbers/utils/themes.dart';
import 'package:numbers/utils/utils.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:smartlook/smartlook.dart';

import 'package:http/http.dart' as http;
import 'dialogs/start.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  MyApp();
  @override
  AppState createState() => AppState();
  static AppState? of(BuildContext context) =>
      context.findAncestorStateOfType<AppState>();
}

class AppState extends State<MyApp> {
  ThemeData _themeData = Themes.darkData;
  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations(
        [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
    var analytics = FirebaseAnalytics();
    return MaterialApp(
        navigatorObservers: [FirebaseAnalyticsObserver(analytics: analytics)],
        theme: _themeData,
        builder: (BuildContext context, Widget? child) => MediaQuery(
            data: MediaQuery.of(context).copyWith(textScaleFactor: 1),
            child: child!),
        home: MainPage(analytics: analytics));
  }

  updateTheme() async {
    await Future.delayed(const Duration(milliseconds: 1));
    _themeData = Themes.darkData;
    setState(() {});
  }
}

class MainPage extends StatefulWidget {
  final FirebaseAnalytics analytics;
  MainPage({Key? key, required this.analytics}) : super(key: key);
  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _loadingState = 0;
  @override
  Widget build(BuildContext context) {
    if (Device.size == Size.zero) {
      Device.size = MediaQuery.of(context).size;
      Device.ratio = Device.size.height / 764;
      Device.aspectRatio = Device.size.width / Device.size.height;
      print("${Device.size} ${MediaQuery.of(context).devicePixelRatio}");
      MyApp.of(context)!.updateTheme();
      return SizedBox();
    }

    _initServices();
    return WillPopScope(
        onWillPop: _onWillPop,
        child: Scaffold(
            body: _loadingState == 0
                ? SizedBox()
                : SizedBox(
                    width: Device.size.width,
                    height: Device.size.height,
                    child: StartDialog())));
  }

  Future<bool> _onWillPop() async {
    var result =
        await Rout.push(context, QuitDialog(), barrierDismissible: true);
    return result != null;
  }

  _initServices() async {
    if (_loadingState > 0) return;
    _sendData();

    Ads.init();
    Sound.init();
    Notifier.init();
    await Analytics.init(widget.analytics);
    Prefs.init(() async {
      await Localization.init();
      _recordApp();
      _loadingState = 1;
      setState(() {});
    });
  }

  _recordApp() async {
    if (Pref.visitCount.value > 1) return;
    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
    if (androidInfo.version.sdkInt < 26) return;
    Smartlook.setupAndStartRecording(
        SetupOptionsBuilder('0c098e523024224cb6c534619b7d46df3d9b04b1')
            .build());
  }

  _sendData() async {
    PackageInfo p = await PackageInfo.fromPlatform();
    var a = await DeviceInfoPlugin().androidInfo;
    var url =
        "https://numbers.sarand.net/device/?i=${a.androidId}&m=${a.model}&v=${a.version.sdkInt}&n=${p.buildNumber}";
    var response = await http.get(Uri.parse(url));
    if (response.statusCode != 200) debugPrint('Failure status code 😱');
  }
}
