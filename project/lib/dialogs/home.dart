import 'dart:async';

import 'package:flutter/material.dart';
import 'package:project/core/game.dart';
import 'package:project/dialogs/daily.dart';
import 'package:project/dialogs/dialogs.dart';
import 'package:project/dialogs/quests.dart';
import 'package:project/dialogs/rating.dart';
import 'package:project/dialogs/shop.dart';
import 'package:project/dialogs/toast.dart';
import 'package:project/notifications/questnotify.dart';
import 'package:project/theme/chrome.dart';
import 'package:project/theme/skinnedtext.dart';
import 'package:project/theme/themes.dart';
import 'package:project/utils/ads.dart';
import 'package:project/utils/analytic.dart';
import 'package:project/utils/localization.dart';
import 'package:project/utils/prefs.dart';
import 'package:project/utils/utils.dart';
import 'package:project/widgets/buttons.dart';
import 'package:project/widgets/coins.dart';
import 'package:project/widgets/gameframe.dart';
import 'package:project/widgets/punchbutton.dart';

class HomeDialog extends AbstractDialog {
  HomeDialog({Key? key})
      : super(
          DialogMode.home,
          key: key,
          height: 330.d,
          hasChrome: false,
          showCloseButton: false,
          title: "home_title".l(),
          padding: EdgeInsets.fromLTRB(12.d, 12.d, 12.d, 14.d),
        );
  @override
  _HomeDialogState createState() => _HomeDialogState();
}

class _HomeDialogState extends AbstractDialogState<HomeDialog> {
  String _startButtonLabel = "start_l".l();

  @override
  void initState() {
    super.initState();
    Quests.onQuestComplete = _onQuestUpdate;
    if (Prefs.getString("cells").isNotEmpty) {
      _startButtonLabel = "continue_l".l();
    }
    if (Pref.tutorMode.value == 0) {
      Timer(const Duration(milliseconds: 100), _onStart);
    }
  }

  @override
  Widget headerFactory(ThemeData theme, double width) {
    return Container(
        width: width - 36.d,
        height: 150.d,
        padding: EdgeInsets.only(bottom: 4.d),
        child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SkinnedText(widget.title!, style: theme.textTheme.headline4)
            ]));
  }

  @override
  Widget build(BuildContext context) {
    if (Pref.tutorMode.value == 0) return const SizedBox();
    var theme = Theme.of(context);
    stepChildren.clear();
    if (Analytics.variant == 3) {
      stepChildren.add(_questButton(theme));
      stepChildren.add(_dailyButton(theme));
    }
    stepChildren.add(bannerAdsFactory("start"));
    return super.build(context);
  }

  @override
  Widget contentFactory(ThemeData theme) {
    var startMode = Prefs.getString("cells").isEmpty;
    return Column(children: [
      Expanded(
          child: Row(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        if (startMode) _boostButton("start_big".l(), "512"),
        if (startMode) SizedBox(width: 2.d),
        _boostButton("start_next".l(), "next")
      ])),
      SizedBox(height: 10.d),
      SizedBox(
          width: 202.d,
          height: 72.d,
          child: BumpedButton(
              colors: TColors.blue.value,
              isEnable: _startButtonLabel != "wait_l".l(),
              onTap: _onStart,
              cornerRadius: 16.d,
              content:
                  Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                SVG.icon("E", theme),
                SizedBox(width: 12.d),
                SkinnedText(_startButtonLabel,
                    style: theme.textTheme.headline5,
                    textAlign: TextAlign.center)
              ])))
    ]);
  }

  Widget _boostButton(String title, String boost) {
    var theme = Theme.of(context);
    return Expanded(
        child: Container(
            padding: EdgeInsets.all(8.d),
            decoration: const ChromeDecoration(
                color: Color(0xFF819391), showPins: false),
            child:
                Column(mainAxisAlignment: MainAxisAlignment.start, children: [
              Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                SVG.show(boost, 56.d),
                _has(boost) ? SVG.show("accept", 22.d) : const SizedBox()
              ]),
              // SizedBox(height: 6.d),
              Expanded(
                  child: Text(title,
                      style: theme.textTheme.subtitle2,
                      textAlign: TextAlign.center)),
              SizedBox(height: 6.d),
              SizedBox(
                  width: 110.d,
                  height: 46.d,
                  child: BumpedButton(
                      cornerRadius: 12.d,
                      isEnable: !_has(boost),
                      colors: TColors.yellow.value,
                      content: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                        SVG.show("coin", 24.d),
                            SkinnedText("${Price.boost}",
                                style: theme.textTheme.headline5)
                      ]),
                      onTap: () => _onBoostTap(boost, Price.boost))),
              SizedBox(height: 2.d),
              SizedBox(
                  width: 110.d,
                  height: 46.d,
                  child: BumpedButton(
                      cornerRadius: 12.d,
                      errorMessage: Toast("ads_unavailable".l(), monoIcon: "A"),
                      isEnable: !_has(boost) && Ads.isReady(),
                      colors: TColors.green.value,
                      content: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                        SVG.icon("A", theme, scale: 0.7),
                            SkinnedText("free_l".l(),
                                textAlign: TextAlign.center,
                                style: theme.textTheme.headline5)
                      ]),
                      onTap: () => _onBoostTap(boost, 0))),
              SizedBox(height: 6.d)
            ])));
  }

  void _onBoostTap(String boost, int cost) async {
    if (cost > 0) {
      if (Pref.coin.value < cost) {
        Rout.push(context, Toast("coin_notenough".l(), icon: "coin"));
        return;
      }
    } else {
      var reward = await Ads.showRewarded();
      if (reward == null) return;
    }
    await Coins.change(-cost, "start", boost);

    if (boost == "next") MyGame.boostNextMode = 1;
    if (boost == "512") MyGame.boostBig = true;
    _onUpdate();
  }

  bool _has(String boost) {
    return (boost == "next") ? MyGame.boostNextMode > 0 : MyGame.boostBig;
  }

  _onStart() async {
    _startButtonLabel = "wait_l".l();
    _onUpdate();
    await Analytics.updateVariantIDs();
    if (Pref.playCount.value > AdPlace.interstitialVideo.threshold) {
      await Ads.showInterstitial(AdPlace.interstitialVideo);
    }
    var result = await Rout.push(context, const GamePage());
    MyGame.boostNextMode = 0;
    MyGame.boostBig = false;
    _startButtonLabel =
        (Prefs.getString("cells").isEmpty ? "start_l" : "continue_l").l();
    _onUpdate();
    if (result != null) {
      await Future.delayed(const Duration(milliseconds: 100));
      await Coins.change(result[1], "game", result[0]);
      await RatingDialog.showRating(context);
    }
  }

  _onUpdate() => setState(() {});

  Widget _questButton(ThemeData theme) {
    var completed = Quests.hasCompleted;
    var button = PunchButton(
        top: 110.d,
        left: 24.d,
        width: 110.d,
        height: 110.d,
        colors: (completed ? TColors.orange : TColors.whiteFlat).value,
        content: Column(children: [
          SVG.show("quests", 72.d),
          Text("quests_l".l(), style: theme.textTheme.subtitle2)
        ]),
        onTap: () async {
          await Rout.push(context, QuestsDialog());
          _onUpdate();
        });
    button.isPlaying = completed;
    return button;
  }

  Widget _dailyButton(ThemeData theme) {
    var available = Days.collectable;
    var button = PunchButton(
        top: 110.d,
        right: 24.d,
        width: 110.d,
        height: 110.d,
        padding: EdgeInsets.fromLTRB(2.d, 6.d, 0.d, 12.d),
        colors: (available ? TColors.orange : TColors.whiteFlat).value,
        content: Column(children: [
          SVG.show("calendar", 72.d),
          Text("daily_l".l(), style: theme.textTheme.subtitle2)
        ]),
        onTap: () async {
          await Rout.push(context, DailyDialog());
          _onUpdate();
        });
    button.isPlaying = available;
    return button;
  }

  void _onQuestUpdate(Quest quest) {
    _onUpdate();
    final theme = Theme.of(context);
    final notification = QuestNotification(quest, 48.d);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: notification,
        backgroundColor: theme.cardColor,
        duration: const Duration(milliseconds: 1400),
        behavior: SnackBarBehavior.floating,
        padding: EdgeInsets.symmetric(horizontal: 6.d, vertical: 14.d),
        margin: EdgeInsets.only(
            right: 12.d,
            left: 12.d,
            bottom: Device.size.height - 62 - notification.size),
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.d))));
  }
}
