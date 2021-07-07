import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:numbers/core/cell.dart';
import 'package:numbers/utils/prefs.dart';
import 'package:numbers/utils/sounds.dart';
import 'package:numbers/utils/themes.dart';
import 'package:numbers/utils/utils.dart';
import 'package:numbers/widgets/buttons.dart';
import 'package:numbers/widgets/components.dart';
import 'package:numbers/widgets/widgets.dart';
import 'package:rive/rive.dart';

class Overlays {
  static Widget basic(BuildContext context,
      {Widget? content,
      double? width,
      double? height,
      String? title,
      EdgeInsets? padding,
      bool hasChrome = true,
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
                  title != null
                      ? Text(title, style: theme.textTheme.bodyText2)
                      : SizedBox(),
                  if (hasClose)
                    GestureDetector(
                        child: SVG.show("close", 28),
                        onTap: () => Navigator.of(context).pop())
                ])),
        Container(
            width: width ?? 300,
            height: height ?? 340,
            padding: padding ?? EdgeInsets.fromLTRB(18, 12, 18, 28),
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
            Center(
                heightFactor: 0.85,
                child: RiveAnimation.asset('anims/nums-revive.riv',
                    stateMachines: ["machine"])),
            Positioned(
                height: 76,
                width: 124,
                bottom: 0,
                left: 0,
                child: Buttons.button(
                    onTap: () => _buttonsClick(context, "revive_coin"),
                    cornerRadius: 16,
                    content: Stack(alignment: Alignment.centerLeft, children: [
                      SVG.show("coin", 36),
                      Positioned(
                          top: 5,
                          left: 40,
                          child: Text("100", style: theme.textTheme.button)),
                      Positioned(
                          bottom: 7,
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
                    onTap: () => _buttonsClick(context, "revive_ads"),
                    colors: Themes.swatch[TColors.orange],
                    cornerRadius: 16,
                    content: Stack(alignment: Alignment.centerLeft, children: [
                      SVG.show("ads", 36),
                      Positioned(
                          top: 5,
                          left: 40,
                          child:
                              Text("Free", style: theme.textTheme.headline4)),
                      Positioned(
                          bottom: 7,
                          left: 40,
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
        content: Stack(
          alignment: Alignment.topCenter,
          children: [
            Center(
                heightFactor: 0.52,
                child: RiveAnimation.asset('anims/nums-record.riv',
                    stateMachines: ["machine"])),
            Positioned(
                top: 152,
                child: Text("New Record", style: theme.textTheme.caption)),
            Positioned(
                top: 166,
                child: Text(Prefs.score.format(),
                    style: theme.textTheme.headline2)),
            Positioned(
                height: 76,
                width: 124,
                bottom: 0,
                left: 0,
                child: Buttons.button(
                    onTap: () => _buttonsClick(context, "record_coin"),
                    cornerRadius: 16,
                    content: Stack(alignment: Alignment.centerLeft, children: [
                      SVG.show("coin", 36),
                      Positioned(
                          top: 5,
                          left: 40,
                          child: Text(recordReward.format(),
                              style: theme.textTheme.button)),
                      Positioned(
                          bottom: 7,
                          left: 40,
                          child:
                              Text("Claim", style: theme.textTheme.subtitle1)),
                    ]))),
            Positioned(
                height: 76,
                width: 124,
                bottom: 0,
                right: 0,
                child: Buttons.button(
                    onTap: () => _buttonsClick(context, "record_ads"),
                    colors: Themes.swatch[TColors.orange],
                    cornerRadius: 16,
                    content: Stack(alignment: Alignment.centerLeft, children: [
                      SVG.show("ads", 36),
                      Positioned(
                          top: 5,
                          left: 44,
                          child: Text((recordReward * rewardCoef).format(),
                              style: theme.textTheme.headline4)),
                      Positioned(
                          bottom: 7,
                          left: 44,
                          child: Row(children: [
                            SVG.show("coin", 22),
                            Text("x$rewardCoef",
                                style: theme.textTheme.headline6)
                          ])),
                    ])))
          ]
        ));
  }

  static bigValue(BuildContext context, int value) {
    var theme = Theme.of(context);
    return basic(context,
        height: 380,
        title: "Big Block",
        hasClose: false,
        content: Stack(alignment: Alignment.topCenter, children: [
          Positioned(
              top: 0,
              width: 200,
              height: 200,
              child: RiveAnimation.asset('anims/nums-shine.riv',
                  stateMachines: ["machine"])),
          Positioned(
              top: 58,
              width: 80,
              height: 80,
              child: RotationTransition(
                turns: AlwaysStoppedAnimation(-0.02),
                child: Widgets.cell(theme, value),
              )),
          Positioned(
              top: 170,
              child: Text("Congnratulation.\nYou made ${Cell.getScore(value)}!",
                  style: theme.textTheme.caption, textAlign: TextAlign.center)),
          Positioned(
              top: 225,
              child:
                  Text("Earn more reward?", style: theme.textTheme.headline6)),
          Positioned(
              height: 76,
              width: 124,
              bottom: 0,
              left: 0,
              child: Buttons.button(
                  onTap: () => _buttonsClick(context, "record_coin"),
                  cornerRadius: 16,
                  content: Stack(alignment: Alignment.centerLeft, children: [
                    SVG.show("coin", 36),
                    Positioned(
                        top: 5,
                        left: 40,
                        child: Text(recordReward.format(),
                            style: theme.textTheme.button)),
                    Positioned(
                        bottom: 7,
                        left: 40,
                        child: Text("Claim", style: theme.textTheme.subtitle1)),
                  ]))),
          Positioned(
              height: 76,
              width: 124,
              bottom: 0,
              right: 0,
              child: Buttons.button(
                  onTap: () => _buttonsClick(context, "record_ads"),
                  colors: Themes.swatch[TColors.orange],
                  cornerRadius: 16,
                  content: Stack(alignment: Alignment.centerLeft, children: [
                    SVG.show("ads", 36),
                    Positioned(
                        top: 5,
                        left: 44,
                        child: Text((recordReward * rewardCoef).format(),
                            style: theme.textTheme.headline4)),
                    Positioned(
                        bottom: 7,
                        left: 44,
                        child: Row(children: [
                          SVG.show("coin", 22),
                          Text("x$rewardCoef", style: theme.textTheme.headline6)
                        ])),
                  ])))
        ]));
  }

  static start(BuildContext context, Function() callback) {
    var theme = Theme.of(context);
    return basic(context,
        hasClose: false,
        title: "Select Boost Items",
        padding: EdgeInsets.fromLTRB(12, 12, 12, 16),
        content:
            Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          Expanded(
              child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                Components.startButton(theme, "Start the game with black 512!",
                    SVG.show("ice", 32)),
                Components.startButton(theme,
                    "Preview the next upcoming black!", SVG.show("ice", 32))
              ])),
          SizedBox(height: 4),
          Container(
              height: 76,
              child: Buttons.button(
                  colors: Themes.swatch[TColors.blue],
                  onTap: callback,
                  cornerRadius: 16,
                  content: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SVG.show("play", 32),
                        SizedBox(width: 12),
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
