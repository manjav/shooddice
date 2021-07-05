import 'package:numbers/core/game.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:numbers/utils/sounds.dart';
import 'package:numbers/utils/themes.dart';
import 'package:numbers/widgets/buttons.dart';

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

  void initState() {
    Sound.init();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: HomePage());
  }
}
