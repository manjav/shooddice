import 'package:flame/game.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:numbers/core/game.dart';
import 'package:numbers/overlays/all.dart';
import 'package:numbers/overlays/pause.dart';
import 'package:numbers/utils/utils.dart';
import 'package:numbers/widgets/components.dart';

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
    _game = MyGame(
        onScore: _onGameCallbacks,
        onRecord: _onGameCallbacks,
        onLose: _onGameLose);
  }

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    return Scaffold(
        body: Stack(children: [
      GameWidget(game: _game!),
      Positioned(top: 82, right: 34, child: Components.scores(theme)),
      Positioned(
          top: 84,
          left: 34,
          child: Components.coins(theme, onTap: _onGameLose)),
      Positioned(
          bottom: 70,
          left: 20,
          width: 72,
          height: 72,
          child: IconButton(icon: SVG.show("pause", 48), onPressed: _pause)),
      Positioned(
          bottom: 60,
          right: 20,
          width: 90,
          height: 90,
          child:
              IconButton(icon: SVG.show("remove-one", 64), onPressed: () {})),
      Positioned(
          bottom: 60,
          right: 100,
          width: 90,
          height: 90,
          child:
              IconButton(icon: SVG.show("remove-color", 64), onPressed: () {})),
    ]));
  }

  void _createGame() {
    _game = MyGame(
        onScore: _onGameCallbacks,
        onRecord: _onGameCallbacks,
        onLose: _onGameLose);
    setState(() {});
  }

  void _onGameCallbacks(int score) {
    setState(() {});
  }

  void _onGameLose() {
    Navigator.of(context).push(new PageRouteBuilder(
        barrierColor: Theme.of(context).backgroundColor.withAlpha(180),
        pageBuilder: (BuildContext context, _, __) =>
            Overlays.record(context, _createGame)));
  }

  void _pause({bool showMenu = true}) {
    _game!.isPlaying = false;
    if (!showMenu) return;
    Navigator.of(context).push(new PageRouteBuilder(
        // opaque: false,
        barrierColor: Theme.of(context).backgroundColor.withAlpha(180),
        // barrierDismissible: true,
        pageBuilder: (BuildContext context, _, __) =>
            PauseOverlay(onUpdate: _onPauseButtonsClick)));
  }

  void _onPauseButtonsClick(String type) {
    switch (type) {
      case "reset":
        _createGame();
        break;
      case "resume":
        _game!.isPlaying = true;
        break;
    }
  }

  @override
  void dispose() {
    super.dispose();
  }
}
