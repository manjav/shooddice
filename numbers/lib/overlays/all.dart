import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:games_services/games_services.dart';
import 'package:numbers/core/cell.dart';
import 'package:numbers/overlays/shop.dart';
import 'package:numbers/utils/ads.dart';
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
          child: scoreButton ??
              Components.scores(theme,
                  onTap: () => GamesServices.showLeaderboards())),
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

  static revive(BuildContext context, int numRevive) {
    var theme = Theme.of(context);
    var cost = 100 * pow(2, numRevive).round();
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
                    onTap: () => _buttonsClick(context, "revive", -cost),
                    cornerRadius: 16.d,
                    content: Stack(alignment: Alignment.centerLeft, children: [
                      SVG.show("coin", 36.d),
                      Positioned(
                          top: 5.d,
                          left: 40.d,
                          child: Text("${cost.format()}",
                              style: theme.textTheme.button)),
                      Positioned(
                          bottom: 7.d,
                          left: 40.d,
                          child:
                              Text("Revive", style: theme.textTheme.subtitle1)),
                    ]))),
            Positioned(
                height: 76.d,
                width: 124.d,
                bottom: 0,
                right: 0,
                child: Buttons.button(
                    cornerRadius: 16.d,
                    isEnable: numRevive < 2 && Ads.isReady(),
                    onTap: () => _buttonsClick(context, "revive", 0,
                        adId: AdPlace.Rewarded),
                    colors: TColors.orange.value,
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

  static int rewardCoef = 2;
  static record(BuildContext context) {
    var reward = 100;
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
                  onTap: () => _buttonsClick(context, "record", reward),
                  cornerRadius: 16.d,
                  content: Stack(alignment: Alignment.centerLeft, children: [
                    SVG.show("coin", 36.d),
                    Positioned(
                        top: 5.d,
                        left: 40.d,
                        child: Text(reward.format(),
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
                  cornerRadius: 16.d,
                  isEnable: Ads.isReady(),
                  colors: TColors.orange.value,
                  onTap: () => _buttonsClick(
                      context, "record", rewardCoef * reward,
                      adId: AdPlace.Rewarded),
                  content: Stack(alignment: Alignment.centerLeft, children: [
                    SVG.icon("0", theme),
                    Positioned(
                        top: 5.d,
                        left: 44.d,
                        child: Text((rewardCoef * reward).format(),
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
    var reward = value * 20;
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
                  onTap: () => _buttonsClick(context, "big", reward),
                  cornerRadius: 16.d,
                  content: Stack(alignment: Alignment.centerLeft, children: [
                    SVG.show("coin", 36.d),
                    Positioned(
                        top: 5.d,
                        left: 40.d,
                        child: Text(reward.format(),
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
                  cornerRadius: 16.d,
                  isEnable: Ads.isReady(),
                  colors: TColors.orange.value,
                  onTap: () => _buttonsClick(
                      context, "big", reward * rewardCoef,
                      adId: AdPlace.Rewarded),
                  content: Stack(alignment: Alignment.centerLeft, children: [
                    SVG.icon("0", theme),
                    Positioned(
                        top: 5.d,
                        left: 44.d,
                        child: Text((reward * rewardCoef).format(),
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

  static Widget? endTutorial(BuildContext context) {
    var theme = Theme.of(context);
    return basic(context,
        sfx: "win",
        title: "Good Job!",
        height: 200,
        width: 340,
        hasClose: false,
        content: Stack(alignment: Alignment.topCenter, children: [
          // Center(
          //     heightFactor: 0.52,
          //     child: RiveAnimation.asset('anims/nums-record.riv',
          //         stateMachines: ["machine"])),
          Positioned(
              top: 20.d,
              child: Text("Now lets try the next larg number.\nAre you ready?",
                  style: theme.textTheme.caption)),
          Positioned(
              height: 76.d,
              width: 140.d,
              bottom: 0,
              left: 0,
              child: Buttons.button(
                  onTap: () => Navigator.of(context).pop("tutorReset"),
                  colors: TColors.green.value,
                  cornerRadius: 16.d,
                  content: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        SVG.icon("5", theme),
                        Text("Replay", style: theme.textTheme.headline5)
                      ]))),
          Positioned(
              height: 76.d,
              width: 140.d,
              bottom: 0,
              right: 0,
              child: Buttons.button(
                  onTap: () => Navigator.of(context).pop("tutorFinish"),
                  colors: TColors.blue.value,
                  cornerRadius: 16.d,
                  content: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        SVG.icon("4", theme),
                        Text("Ok", style: theme.textTheme.headline5)
                      ]))),
        ]));
  }

  static start(BuildContext context, Function() callback, Function onUpdate) {
    var theme = Theme.of(context);
    return basic(context,
        hasClose: false,
        title: "Select Boost Items",
        padding: EdgeInsets.fromLTRB(12.d, 12.d, 12.d, 14.d),
        content:
            Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          Expanded(
              child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                Components.startButton(
                    context, "Start the game with black 512!", "512", onUpdate),
                Components.startButton(context,
                    "Preview the next upcoming black!", "next", onUpdate)
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

  static callout(BuildContext context, String title, String type,
      {EdgeInsets? padding}) {
    var cost = 100;
    Sound.play("pop");
    var theme = Theme.of(context);
    return Stack(children: [
      Positioned(
          left: padding != null && padding.left != 0 ? padding.left : null,
          top: padding != null && padding.top != 0 ? padding.top : null,
          right: padding != null && padding.right != 0 ? padding.right : null,
          bottom:
              padding != null && padding.bottom != 0 ? padding.bottom : null,
          child: Container(
              width: 220.d,
              height: 84.d,
              padding: EdgeInsets.all(8.d),
              decoration: BoxDecoration(
                  boxShadow: [
                    BoxShadow(
                        blurRadius: 3,
                        color: Colors.black,
                        offset: Offset(0.5, 2))
                  ],
                  color: theme.cardColor,
                  shape: BoxShape.rectangle,
                  borderRadius: BorderRadius.all(Radius.circular(16))),
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(title, style: theme.textTheme.subtitle2),
                    Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          SizedBox(
                              width: 98,
                              height: 40,
                              child: Buttons.button(
                                  cornerRadius: 8.d,
                                  content: Row(children: [
                                    SVG.show("coin", 24.d),
                                    Expanded(
                                        child: Text("100",
                                            textAlign: TextAlign.center,
                                            style: theme.textTheme.bodyText2))
                                  ]),
                                  onTap: () =>
                                      _buttonsClick(context, type, -cost))),
                          SizedBox(
                              width: 98.d,
                              height: 40.d,
                              child: Buttons.button(
                                  cornerRadius: 8.d,
                                  isEnable: Ads.isReady(),
                                  colors: TColors.orange.value,
                                  content: Row(children: [
                                    SVG.icon("0", theme, scale: 0.7),
                                    Expanded(
                                        child: Text("Free",
                                            textAlign: TextAlign.center,
                                            style: theme.textTheme.headline5))
                                  ]),
                                  onTap: () => _buttonsClick(context, type, 0,
                                      adId: AdPlace.Rewarded)))
                        ])
                  ])))
    ]);
  }

  static Widget quit(BuildContext context) {
    var theme = Theme.of(context);
    return basic(context,
        hasClose: false,
        coinButton: SizedBox(),
        scoreButton: SizedBox(),
        padding: EdgeInsets.fromLTRB(16, 4, 16, 8),
        height: 54,
        title: "Quit",
        content:
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text("Are you sure?", style: theme.textTheme.headline5),
          GestureDetector(
              child: SVG.show("accept", 28.d),
              onTap: () => _buttonsClick(context, "quit", 0))
        ]));
  }

  static _buttonsClick(BuildContext context, String type, int coin,
      {AdPlace? adId}) async {
    if (coin < 0 && Pref.coin.value < -coin) {
      Rout.push(context, ShopOverlay());
      return;
    }
    if (adId != null) {
      var complete = await Ads.show(adId);
      if (!complete) {
        // Navigator.of(context).pop(null);
        return;
      }
    }
    if (coin != 0) Pref.coin.increase(coin);
    Navigator.of(context).pop(type);
  }
}
