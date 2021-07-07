import 'package:flutter/material.dart';
import 'package:numbers/utils/prefs.dart';
import 'package:numbers/utils/sounds.dart';
import 'package:numbers/utils/themes.dart';
import 'package:numbers/widgets/home.dart';

import 'overlays/all.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(theme: Themes.darkData, home: MainPage());
  }
}

class MainPage extends StatefulWidget {
  MainPage({Key? key}) : super(key: key);
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MainPage> {
  int _loadingState = 0;

  @override
  Widget build(BuildContext context) {
    if (_loadingState == 0) {
      Sound.init();
      Prefs.init(() {
        _loadingState = 1;
        setState(() {});
      });
    }
    return Scaffold(body: _getPage());
  }

  Widget _getPage() {
    switch (_loadingState) {
      case 1:
        return Overlays.start(context, () => setState(() => _loadingState = 2));
      case 2:
        return HomePage(() => setState(() => _loadingState = 1));
      default:
        return SizedBox();
    }
  }
}
