import 'package:appsflyer_sdk/appsflyer_sdk.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_analytics/observer.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:numbers/utils/ads.dart';
import 'package:numbers/utils/notification.dart';
import 'package:numbers/utils/prefs.dart';
import 'package:numbers/utils/sounds.dart';
import 'package:numbers/utils/themes.dart';
import 'package:numbers/utils/utils.dart';
import 'package:numbers/widgets/home.dart';

import 'core/game.dart';
import 'overlays/all.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  static FirebaseAnalytics analytics = FirebaseAnalytics();
  static FirebaseAnalyticsObserver observer =
      FirebaseAnalyticsObserver(analytics: analytics);
  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations(
        [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
    return MaterialApp(
        navigatorObservers: <NavigatorObserver>[observer],
        theme: Themes.darkData,
        builder: (BuildContext context, Widget? child) => MediaQuery(
            data: MediaQuery.of(context).copyWith(textScaleFactor: 1),
            child: child!),
        home: MainPage());
  }
}

class MainPage extends StatefulWidget {
  MainPage({Key? key}) : super(key: key);
  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _loadingState = 0;
  @override
  Widget build(BuildContext context) {
    Device.ratio = MediaQuery.of(context).size.width / 360;
    print(
        "${MediaQuery.of(context).size} ${MediaQuery.of(context).devicePixelRatio}");
    if (_loadingState == 0) {
      Ads.init();
      Sound.init();
      Notifier.init();
      Prefs.init(() {
        _loadingState = 1;
        setState(() {});
      });


      var appsflyerSdk = AppsflyerSdk({
        "afDevKey": "YBThmUqaiHZYpiSwZ3GQz4",
        "afAppId": "game.block.puzzle.drop.the.number.merge",
        "isDebug": false
      });
      appsflyerSdk.initSdk(
          registerConversionDataCallback: true,
          registerOnAppOpenAttributionCallback: true,
          registerOnDeepLinkingCallback: true);
    }
    return WillPopScope(
        onWillPop: _onWillPop, child: Scaffold(body: _getPage()));
  }

  Widget _getPage() {
    switch (_loadingState) {
      case 1:
        return Overlays.start(context, () => setState(() => _loadingState = 2),
            () => setState(() {}));
      case 2:
        return HomePage(_onHomeBack);
      default:
        return SizedBox();
    }
  }

  void _onHomeBack() {
    MyGame.boostNextMode = 0;
    MyGame.boostBig = false;
    setState(() => _loadingState = 1);
  }

  Future<bool> _onWillPop() async {
    if (_loadingState == 2) MyGame.isPlaying = false;
    var result = await Rout.push(context, Overlays.quit(context),
        barrierDismissible: true);
    MyGame.isPlaying = true;
    return result != null;
  }
}
