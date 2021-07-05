import 'package:numbers/core/game.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:numbers/utils/sounds.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        theme: ThemeData(primarySwatch: Colors.blue), home: MyHomePage());
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key}) : super(key: key);
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  MyGame? _game;

  void initState() {
    super.initState();
    Sound.init();
    _game = MyGame(onScore: _onGameCallbacks, onRecord: _onGameCallbacks);
  }

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    return Scaffold(
        body: Stack(children: [
      GameWidget(game: _game!),
    ]));
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _onGameCallbacks(int score) {
    setState(() {});
  }
}
