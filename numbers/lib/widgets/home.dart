import 'package:flame/game.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:numbers/core/game.dart';
import 'package:numbers/utils/utils.dart';
import 'package:numbers/utils/prefs.dart';

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
                  child: Text("${Pref.coin.value.format()}",
                      textAlign: TextAlign.center,
                      style: theme.textTheme.button)),
              Text("+  ",
                  textAlign: TextAlign.center, style: theme.textTheme.button)
            ]),
            onTap: () => print("object"),
          )),
      Positioned(
        top: 86,
        right: 24,
        child: SvgPicture.asset("assets/images/cup.svg", width: 48),
      ),
      Positioned(
        top: 82,
        right: 80,
        child: Text(_game!.score.format(), style: theme.textTheme.headline4),
      ),
      Positioned(
        top: 110,
        right: 80,
        child: Text("${Pref.record.value.format()}",
            style: theme.textTheme.headline5),
      ),
      Positioned(
          bottom: 70,
          left: 20,
          width: 72,
          height: 72,
          child: IconButton(
              icon: SvgPicture.asset("assets/images/pause.svg", width: 48),
              onPressed: () {})),
      Positioned(
          bottom: 60,
          right: 20,
          width: 90,
          height: 90,
          child: IconButton(
              icon: SvgPicture.asset("assets/images/remove-one.svg", width: 64),
              onPressed: () {})),
      Positioned(
          bottom: 60,
          right: 100,
          width: 90,
          height: 90,
          child: IconButton(
              icon:
                  SvgPicture.asset("assets/images/remove-color.svg", width: 64),
              onPressed: () {}))
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
