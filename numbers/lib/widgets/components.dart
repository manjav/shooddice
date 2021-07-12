import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:numbers/core/game.dart';
import 'package:numbers/overlays/shop.dart';
import 'package:numbers/utils/prefs.dart';
import 'package:numbers/utils/themes.dart';
import 'package:numbers/utils/utils.dart';
import 'package:numbers/widgets/buttons.dart';

class Components {
  static Widget scores(ThemeData theme) {
    return Hero(
        tag: "score",
        child: Row(children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(Prefs.score.format(), style: theme.textTheme.headline4),
              Text("${Pref.record.value.format()}",
                  style: theme.textTheme.headline5)
              ]),
          SizedBox(width: 4.d),
          SVG.show("cup", 48.d),
        ]));
  }

  static Widget coins(BuildContext context,
      {Function()? onTap, bool clickable = true}) {
    var theme = Theme.of(context);
    var text = "${Pref.coin.value.format()}";
    return Hero(
        tag: "coin",
        child: Buttons.button(
            content: Row(children: [
              SVG.show("coin", 32.d),
              Expanded(
                  child: Text(text,
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyText2!
                          .copyWith(fontSize: text.length > 5 ? 17 : 22))),
              clickable
                  ? Text("+  ",
                      textAlign: TextAlign.center,
                      style: theme.textTheme.button)
                  : SizedBox()
            ]),
            onTap: onTap ??
                () {
                  if (clickable) Rout.push(context, ShopOverlay());
                }));
  }

  static Widget startButton(ThemeData theme, String title, String boost) {
    return Expanded(
        child: Container(
            padding: EdgeInsets.fromLTRB(10.d, 6.d, 10.d, 12.d),
            decoration: CustomDecoration(Themes.swatch[TColors.white]!, 12.d),
            child: Column(mainAxisAlignment: MainAxisAlignment.end, children: [
              SVG.show(boost, 72.d),
              Text(title,
                  style: theme.textTheme.subtitle2,
                  textAlign: TextAlign.center),
              SizedBox(height: 12.d),
              SizedBox(
                  width: 92.d,
                  height: 40.d,
                  child: Buttons.button(
                    cornerRadius: 8.d,
                    content: Row(children: [
                      SVG.show("coin", 24.d),
                      Expanded(
                          child: Text("100",
                              textAlign: TextAlign.center,
                              style: theme.textTheme.bodyText2))
                    ]),
                    onTap: () => _onStartTap(boost, "coin"),
                  )),
              SizedBox(height: 8.d),
              SizedBox(
                  width: 92.d,
                  height: 40.d,
                  child: Buttons.button(
                    cornerRadius: 8.d,
                    colors: Themes.swatch[TColors.orange],
                    content: Row(children: [
                      SVG.icon("0", theme, scale: 0.7),
                      Expanded(
                          child: Text("Free",
                              textAlign: TextAlign.center,
                              style: theme.textTheme.headline5))
                    ]),
                    onTap: () => _onStartTap(boost, "ads"),
                  )),
              SizedBox(height: 4.d)
            ])));
  }

  static _onStartTap(String boost, String type) {
    if (boost == "next") MyGame.boostNextMode = 1;
    if (boost == "512") MyGame.boostBig = true;
  }
}
