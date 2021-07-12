import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:numbers/core/cell.dart';
import 'package:numbers/core/game.dart';
import 'package:numbers/utils/prefs.dart';
import 'package:numbers/utils/sounds.dart';
import 'package:numbers/utils/themes.dart';
import 'package:numbers/utils/utils.dart';
import 'package:numbers/widgets/buttons.dart';
import 'package:numbers/widgets/components.dart';
import 'package:numbers/widgets/widgets.dart';
import 'package:rive/rive.dart';

class Overlays {
  static Widget basic(
    BuildContext context, {
    String? sfx,
    String? title,
    double? width,
    double? height,
    Widget? content,
    Widget? scoreButton,
    Widget? coinButton,
    EdgeInsets? padding,
    bool hasChrome = true,
    bool hasClose = true,
  }) {
    var theme = Theme.of(context);
    Sound.play(sfx ?? "pop");
    return Stack(alignment: Alignment.center, children: [
      Positioned(
          top: 50.d,
          right: 24.d,
          child: scoreButton ?? Components.scores(theme)),
      Positioned(
          top: 52.d,
          left: 24.d,
          child: coinButton ?? Components.coins(context)),
      Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Padding(
            padding: EdgeInsets.fromLTRB(48.d, 64.d, 48.d, 20.d),
            child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  title != null
                      ? Text(title, style: theme.textTheme.headline4)
                      : SizedBox(),
                  if (hasClose)
                    GestureDetector(
                        child: SVG.show("close", 28.d),
                        onTap: () => Navigator.of(context).pop())
                ])),
        Container(
            width: width ?? 300.d,
            height: height ?? 340.d,
            padding: padding ?? EdgeInsets.fromLTRB(18.d, 12.d, 18.d, 28.d),
            decoration: hasChrome
                ? BoxDecoration(
                    color: theme.dialogTheme.backgroundColor,
                    shape: BoxShape.rectangle,
                    borderRadius: BorderRadius.all(Radius.circular(24)))
                : null,
            child: content ?? SizedBox())
      ])
    ]);
  }

  static revive(BuildContext context) {
    var theme = Theme.of(context);
    return basic(context,
        sfx: "lose",
        title: "Revive",
        content: Stack(
          alignment: Alignment.topCenter,
          children: [
            Positioned(
                child:
                    Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              SVG.show("record", 16.d),
              Text(" ${Pref.record.value.format()}",
                  style: theme.textTheme.headline6)
            ])),
            Positioned(
                top: 24.d,
                child: Text(Prefs.score.format(),
                    style: theme.textTheme.headline3)),
            Center(
                heightFactor: 0.85,
                child: RiveAnimation.asset('anims/nums-revive.riv',
                    stateMachines: ["machine"])),
            Positioned(
                height: 76.d,
                width: 124.d,
                bottom: 0,
                left: 0,
                child: Buttons.button(
                    onTap: () => _buttonsClick(context, "revive_coin"),
                    cornerRadius: 16.d,
                    content: Stack(alignment: Alignment.centerLeft, children: [
                      SVG.show("coin", 36.d),
                      Positioned(
                          top: 5.d,
                          left: 40.d,
                          child: Text("100", style: theme.textTheme.button)),
                      Positioned(
                          bottom: 7.d,
                          left: 40.d,
                          child:
                              Text("Revive", style: theme.textTheme.subtitle2)),
                    ]))),
            Positioned(
                height: 76.d,
                width: 124.d,
                bottom: 0,
                right: 0,
                child: Buttons.button(
                    onTap: () => _buttonsClick(context, "revive_ads"),
                    colors: Themes.swatch[TColors.orange],
                    cornerRadius: 16.d,
                    content: Stack(alignment: Alignment.centerLeft, children: [
                      SVG.icon("0", theme),
                      Positioned(
                          top: 5.d,
                          left: 40.d,
                          child:
                              Text("Free", style: theme.textTheme.headline4)),
                      Positioned(
                          bottom: 7.d,
                          left: 40.d,
                          child:
                              Text("Revive", style: theme.textTheme.headline6)),
                    ])))
          ],
        ));
  }

  static int rewardCoef = 3;
  static int recordReward = 100;
  static record(BuildContext context) {
    var theme = Theme.of(context);
    return basic(context,
        sfx: "win",
        content: Stack(alignment: Alignment.topCenter, children: [
          Center(
              heightFactor: 0.52,
              child: RiveAnimation.asset('anims/nums-record.riv',
                  stateMachines: ["machine"])),
          Positioned(
              top: 152.d,
              child: Text("New Record", style: theme.textTheme.caption)),
          Positioned(
              top: 166.d,
              child:
                  Text(Prefs.score.format(), style: theme.textTheme.headline2)),
          Positioned(
              height: 76.d,
              width: 124.d,
              bottom: 0,
              left: 0,
              child: Buttons.button(
                  onTap: () => _buttonsClick(context, "record_coin"),
                  cornerRadius: 16.d,
                  content: Stack(alignment: Alignment.centerLeft, children: [
                    SVG.show("coin", 36.d),
                    Positioned(
                        top: 5.d,
                        left: 40.d,
                        child: Text(recordReward.format(),
                            style: theme.textTheme.button)),
                    Positioned(
                        bottom: 7.d,
                        left: 40.d,
                        child: Text("Claim", style: theme.textTheme.subtitle2)),
                  ]))),
          Positioned(
              height: 76.d,
              width: 124.d,
              bottom: 0,
              right: 0,
              child: Buttons.button(
                  onTap: () => _buttonsClick(context, "record_ads"),
                  colors: Themes.swatch[TColors.orange],
                  cornerRadius: 16.d,
                  content: Stack(alignment: Alignment.centerLeft, children: [
                    SVG.icon("0", theme),
                    Positioned(
                        top: 5.d,
                        left: 44.d,
                        child: Text((recordReward * rewardCoef).format(),
                            style: theme.textTheme.headline4)),
                    Positioned(
                        bottom: 7.d,
                        left: 44.d,
                        child: Row(children: [
                          SVG.show("coin", 22.d),
                          Text("x$rewardCoef", style: theme.textTheme.headline6)
                        ])),
                  ])))
        ]));
  }

  static bigValue(BuildContext context, int value) {
    var theme = Theme.of(context);
    return basic(context,
        sfx: "win",
        height: 380.d,
        hasClose: false,
        title: "Big Block",
        content: Stack(alignment: Alignment.topCenter, children: [
          Positioned(
              top: 0,
              width: 200.d,
              height: 200.d,
              child: RiveAnimation.asset('anims/nums-shine.riv',
                  stateMachines: ["machine"])),
          Positioned(
              top: 58.d,
              width: 80.d,
              height: 80.d,
              child: RotationTransition(
                turns: AlwaysStoppedAnimation(-0.02),
                child: Widgets.cell(theme, value),
              )),
          Positioned(
              top: 170.d,
              child: Text("Congnratulation.\nYou made ${Cell.getScore(value)}!",
                  style: theme.textTheme.caption, textAlign: TextAlign.center)),
          Positioned(
              top: 225.d,
              child:
                  Text("Earn more reward?", style: theme.textTheme.headline6)),
          Positioned(
              height: 76.d,
              width: 124.d,
              bottom: 0,
              left: 0,
              child: Buttons.button(
                  onTap: () => _buttonsClick(context, "record_coin"),
                  cornerRadius: 16.d,
                  content: Stack(alignment: Alignment.centerLeft, children: [
                    SVG.show("coin", 36.d),
                    Positioned(
                        top: 5.d,
                        left: 40.d,
                        child: Text(recordReward.format(),
                            style: theme.textTheme.button)),
                    Positioned(
                        bottom: 7.d,
                        left: 40.d,
                        child: Text("Claim", style: theme.textTheme.subtitle2)),
                  ]))),
          Positioned(
              height: 76.d,
              width: 124.d,
              bottom: 0,
              right: 0,
              child: Buttons.button(
                  onTap: () => _buttonsClick(context, "record_ads"),
                  colors: Themes.swatch[TColors.orange],
                  cornerRadius: 16.d,
                  content: Stack(alignment: Alignment.centerLeft, children: [
                    SVG.icon("0", theme),
                    Positioned(
                        top: 5.d,
                        left: 44.d,
                        child: Text((recordReward * rewardCoef).format(),
                            style: theme.textTheme.headline4)),
                    Positioned(
                        bottom: 7.d,
                        left: 44.d,
                        child: Row(children: [
                          SVG.show("coin", 22.d),
                          Text("x$rewardCoef", style: theme.textTheme.headline6)
                        ])),
                  ])))
        ]));
  }

  static start(BuildContext context, Function() callback) {
    var theme = Theme.of(context);
    MyGame.boostNextMode = 0;
    MyGame.boostBig = false;
    return basic(context,
        hasClose: false,
        title: "Select Boost Items",
        padding: EdgeInsets.fromLTRB(12.d, 12.d, 12.d, 16.d),
        content:
            Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          Expanded(
              child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                Components.startButton(
                    theme, "Start the game with black 512!", "512"),
                Components.startButton(
                    theme, "Preview the next upcoming black!", "next")
              ])),
          SizedBox(height: 4.d),
          Container(
              height: 76.d,
              child: Buttons.button(
                  colors: Themes.swatch[TColors.blue],
                  onTap: callback,
                  cornerRadius: 16.d,
                  content: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SVG.icon("4", theme),
                        SizedBox(width: 12.d),
                        Text("Start",
                            style: theme.textTheme.headline5,
                            textAlign: TextAlign.center)
                      ])))
        ]));
  }

  static _buttonsClick(BuildContext context, String? type) {
    if (type == "revive_coin")
      Pref.coin.set(Pref.coin.value - 100);
    else if (type == "record_coin")
      Pref.coin.set(Pref.coin.value + recordReward);
    else if (type == "record_ads")
      Pref.coin.set(Pref.coin.value + (recordReward * rewardCoef));

    Navigator.of(context).pop(type);
  }
}
