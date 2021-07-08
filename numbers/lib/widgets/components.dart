import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
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
            ],
          ),
          SizedBox(width: 4),
          SVG.show("cup", 48),
        ]));
  }

  static Widget coins(BuildContext context,
      {Function()? onTap, bool clickable = true}) {
    var theme = Theme.of(context);
    return Hero(
        tag: "coin",
        child: Buttons.button(
            content: Row(children: [
              SVG.show("coin", 32),
              Expanded(
                  child: Text("${Pref.coin.value.format()}",
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyText1)),
              clickable
                  ? Text("+  ",
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyText1)
                  : SizedBox()
            ]),
            onTap: onTap ??
                () {
                  if (clickable) Rout.push(context, ShopOverlay());
                }));
  }

  static Widget startButton(ThemeData theme, String title, SvgPicture icon) {
    return Expanded(
        child: Container(
            padding: EdgeInsets.fromLTRB(10, 6, 10, 12),
            decoration: CustomDecoration(Themes.swatch[TColors.white]!, 12),
            child: Column(mainAxisAlignment: MainAxisAlignment.end, children: [
              icon,
              // SizedBox(height: 4),
              Text(title,
                  style: theme.textTheme.subtitle2,
                  textAlign: TextAlign.center),
              SizedBox(height: 12),
              SizedBox(
                  width: 92,
                  height: 40,
                  child: Buttons.button(
                    cornerRadius: 8,
                    content: Row(children: [
                      SVG.show("coin", 24),
                      Expanded(
                          child: Text("100",
                              textAlign: TextAlign.center,
                              style: theme.textTheme.bodyText1))
                    ]),
                    onTap: () {},
                  )),
              SizedBox(height: 8),
              SizedBox(
                  width: 92,
                  height: 40,
                  child: Buttons.button(
                    cornerRadius: 8,
                    colors: Themes.swatch[TColors.orange],
                    content: Row(children: [
                      SVG.show("ads", 20),
                      Expanded(
                          child: Text("Free",
                              textAlign: TextAlign.center,
                              style: theme.textTheme.headline5))
                    ]),
                    onTap: () {},
                  )),
              SizedBox(height: 4)
            ])));
  }
}
