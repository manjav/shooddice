import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:numbers/utils/prefs.dart';
import 'package:numbers/utils/sounds.dart';
import 'package:numbers/utils/themes.dart';
import 'package:numbers/utils/utils.dart';
import 'package:numbers/widgets/buttons.dart';
import 'package:numbers/widgets/components.dart';

class Overlays {
  static Widget basic(BuildContext context,
      {Widget? content,
      double? width,
      double? height,
      String? title,
      bool hasClose = true}) {
    var theme = Theme.of(context);
    Sound.play("pop");
    return Stack(alignment: Alignment.center, children: [
      Positioned(top: 50, right: 24, child: Components.scores(theme)),
      Positioned(top: 52, left: 24, child: Components.coins(theme)),
      Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Padding(
            padding: EdgeInsets.fromLTRB(48, 64, 48, 20),
            child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (title != null)
                    Text(title, style: theme.textTheme.bodyText2),
                  if (hasClose)
                    GestureDetector(
                        child: SVG.show("close", 28),
                        onTap: () => _buttonsClick(context, null, null))
                ])),
        Container(
            width: width ?? 300,
            height: height ?? 340,
            padding: EdgeInsets.fromLTRB(18, 12, 18, 28),
            decoration: BoxDecoration(
                color: theme.dialogTheme.backgroundColor,
                shape: BoxShape.rectangle,
                borderRadius: BorderRadius.all(Radius.circular(24))),
            child: content ?? SizedBox())
      ])
    ]);
  }

  static revive(BuildContext context, Function? callback) {
    var theme = Theme.of(context);
    return basic(context,
        title: "Revive",
        content: Stack(
          alignment: Alignment.topCenter,
          children: [
            Positioned(
                child:
                    Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              SVG.show("record", 16),
              Text(" ${Pref.record.value.format()}",
                  style: theme.textTheme.headline6)
            ])),
            Positioned(
                top: 24,
                child: Text(Prefs.score.format(),
                    style: theme.textTheme.headline3)),
            Center(heightFactor: 1.9, child: SVG.show("heart", 128)),
            Positioned(
                height: 76,
                width: 124,
                bottom: 0,
                left: 0,
                child: Buttons.button(
                    onTap: () => _buttonsClick(context, "coin", callback),
                    cornerRadius: 20,
                    content: Stack(alignment: Alignment.centerLeft, children: [
                      SVG.show("coin", 36),
                      Positioned(
                          top: 5,
                          left: 40,
                          child: Text("100", style: theme.textTheme.button)),
                      Positioned(
                          bottom: 8,
                          left: 40,
                          child: Text("Revive",
                              style: TextStyle(
                                  fontSize: 15,
                                  color: Themes.swatch[TColors.black]![0]))),
                    ]))),
            Positioned(
                height: 76,
                width: 124,
                bottom: 0,
                right: 0,
                child: Buttons.button(
                    onTap: () => _buttonsClick(context, "ads", callback),
                    colors: Themes.swatch[TColors.orange],
                    cornerRadius: 20,
                    content: Stack(alignment: Alignment.centerLeft, children: [
                      SVG.show("ads", 36),
                      Positioned(
                          top: 5,
                          left: 40,
                          child:
                              Text("Free", style: theme.textTheme.headline4)),
                      Positioned(
                          bottom: 8,
                          left: 40,
                          child:
                              Text("Revive", style: theme.textTheme.headline6)),
                    ])))
          ],
        ));
  }

  static _buttonsClick(BuildContext context, String? type, Function? callback) {
    if (type == "ads")
      callback?.call();
    else if (type == "coin") {
      Pref.coin.set(Pref.coin.value - 100);
      callback?.call();
    }
    Navigator.of(context).pop();
  }
}
