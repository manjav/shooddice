import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:numbers/utils/prefs.dart';
import 'package:numbers/utils/themes.dart';
import 'package:numbers/utils/utils.dart';
import 'package:numbers/widgets/buttons.dart';

import 'all.dart';


class PauseOverlay extends StatefulWidget {
  final Function(String) onUpdate;

  PauseOverlay({Key? key, required this.onUpdate}) : super(key: key);
  @override
  _PauseOverlayState createState() => _PauseOverlayState();
}

class _PauseOverlayState extends State<PauseOverlay> {
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    return Overlays.basic(context,
        title: "Pause",
        hasChrome: false,
        hasClose: false,
        padding: EdgeInsets.only(top: 10),
        height: 180,
        content: Stack(
          alignment: Alignment.topCenter,
          children: [
            Positioned(
                height: 76,
                width: 146,
                top: 0,
                left: 0,
                child: Buttons.button(
                    onTap: () => _buttonsClick(context, "reset"),
                    colors: Themes.swatch[TColors.green],
                    cornerRadius: 16,
                    content: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          SVG.show("reset", 26),
                          Text("Restart", style: theme.textTheme.headline5)
                        ]))),
            Positioned(
                height: 76,
                width: 146,
                top: 0,
                right: 0,
                child: Buttons.button(
                    onTap: () => _buttonsClick(context, "resume"),
                    colors: Themes.swatch[TColors.blue],
                    cornerRadius: 16,
                    content: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          SVG.show("play", 26),
                          Text("Continue", style: theme.textTheme.headline5)
                        ]))),
            Positioned(
                height: 76,
                width: 76,
                top: 90,
                left: 66,
                child: Buttons.button(
                    onTap: () => _buttonsClick(context, "resume"),
                    colors: Themes.swatch[TColors.orange],
                    cornerRadius: 16,
                    content: Center(child: SVG.show("noads-mono", 32)))),
            Positioned(
                height: 76,
                width: 76,
                top: 90,
                right: 66,
                child: Buttons.button(
                    onTap: () {
                      Pref.isMute.set(Pref.isMute.value == 0 ? 1 : 0);
                      setState(() {});
                    },
                    colors: Themes.swatch[TColors.yellow],
                    cornerRadius: 16,
                    content: Center(
                        child: SVG.show("mute-${Pref.isMute.value}", 32)))),
          ],
        ));
  }

  _buttonsClick(BuildContext context, String type) {
    widget.onUpdate(type);
    Navigator.of(context).pop();
  }
}
