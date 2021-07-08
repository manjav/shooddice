import 'package:flame/game.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:numbers/core/game.dart';
import 'package:numbers/overlays/all.dart';
import 'package:numbers/overlays/pause.dart';
import 'package:numbers/overlays/shop.dart';
import 'package:numbers/utils/utils.dart';
import 'package:numbers/widgets/components.dart';

class HomePage extends StatefulWidget {
  final Function() onBack;
  HomePage(this.onBack, {Key? key}) : super(key: key);
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  MyGame? _game;
  int loadingState = 0;

  void initState() {
    super.initState();
    _game = MyGame(onGameEvent: _onGameEventHandler);
  }

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    return Scaffold(
        body: Stack(children: [
      GameWidget(game: _game!),
      Positioned(
          top: _game!.bounds.top - 68,
          right: 34,
          child: Components.scores(theme)),
      Positioned(
          top: _game!.bounds.top - 70,
          left: 34,
          child: Components.coins(context, onTap: () async {
            _game!.isPlaying = false;
            await Rout.push(context, ShopOverlay());
            _game!.isPlaying = true;
          })),
      Positioned(
          bottom: 10,
          left: 20,
          width: 72,
          height: 72,
          child: IconButton(icon: SVG.show("pause", 48), onPressed: _pause)),
      Positioned(
          bottom: 0,
          right: 20,
          width: 90,
          height: 90,
          child:
              IconButton(icon: SVG.show("remove-one", 64), onPressed: () {})),
      Positioned(
          bottom: 0,
          right: 100,
          width: 90,
          height: 90,
          child:
              IconButton(icon: SVG.show("remove-color", 64), onPressed: () {})),
    ]));
  }

  void _onGameEventHandler(GameEvent event, int value) async {
    Widget? _widget;
    switch (event) {
      case GameEvent.big:
        _widget = Overlays.bigValue(context, value);
        break;
      case GameEvent.lose:
        _widget = Overlays.revive(context);
        break;
      case GameEvent.record:
        _widget = Overlays.record(context);
        break;
      case GameEvent.score:
        setState(() {});
        return;
    }

    if (_widget != null) {
      var result = await Rout.push(context, _widget);
      if (event == GameEvent.lose) {
        if (result == null) widget.onBack();
        _game!.revive();
        return;
      }
    }
    _onPauseButtonsClick("resume");
  }

  void _pause({bool showMenu = true}) async {
    _game!.isPlaying = false;
    if (!showMenu) return;
    var result = await Rout.push(context, PauseOverlay());
    _onPauseButtonsClick(result ?? "resume");
  }

  void _onPauseButtonsClick(String type) {
    switch (type) {
      case "reset":
        widget.onBack();
        break;
      case "resume":
        _game!.isPlaying = true;
        setState(() {});
        break;
    }
  }
}
