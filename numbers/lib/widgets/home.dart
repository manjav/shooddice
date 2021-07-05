import 'package:flame/game.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:numbers/core/game.dart';

import 'buttons.dart';

class HomePage extends StatefulWidget {
  HomePage({Key? key}) : super(key: key);
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  MyGame? _game;
  int loadingState = 0;

  void initState() {
    super.initState();
    _game = MyGame(onScore: _onGameCallbacks, onRecord: _onGameCallbacks);
  }

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    return Scaffold(
        body: Stack(children: [
      GameWidget(game: _game!),
      Positioned(
          top: 80,
          left: 24,
          child: Buttons.button(
            content: Row(children: [
              SvgPicture.asset(
                "assets/images/coin.svg",
                width: 32,
              ),
              Expanded(
                  child: Text("1,230",
                      textAlign: TextAlign.center,
                      style: theme.textTheme.button)),
              Text("+  ",
                  textAlign: TextAlign.center, style: theme.textTheme.button)
            ]),
            onTap: () => print("object"),
          )),
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
