import 'dart:async';

import 'package:flutter/material.dart';
import 'package:install_prompt/install_prompt.dart';
import 'package:project/core/game.dart';
import 'package:project/dialogs/confirm.dart';
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
          height: 360.d,
          hasChrome: false,
          showCloseButton: false,
          title: "home_title".l(),
          padding: EdgeInsets.fromLTRB(12.d, 12.d, 12.d, 14.d),
        );
  @override
  createState() => _HomeDialogState();
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
    if (Quests.isActive) {
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
        if (startMode) _boostButton(Pref.boostBig),
        if (startMode) SizedBox(width: 2.d),
        _boostButton(Pref.boostNext)
      ])),
      SizedBox(height: 8.d),
      SizedBox(
          width: 202.d,
          height: 70.d,
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
              ]))),
      SizedBox(height: 40.d),
    ]);
  }

  Widget _boostButton(Pref boost) {
    var theme = Theme.of(context);
    var adyCost = Price.boost ~/ Ads.costCoef;
    return Expanded(
        child: Container(
            padding: EdgeInsets.all(8.d),
            decoration: const ChromeDecoration(
                color: Color(0xFF819391), showPins: false),
            child:
                Column(mainAxisAlignment: MainAxisAlignment.start, children: [
              Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                SVG.show(boost.name, 56.d),
                _has(boost) ? SVG.show("accept", 22.d) : const SizedBox()
              ]),
              // SizedBox(height: 6.d),
              Expanded(
                  child: Text("start_${boost.name}".l(),
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
                      onTap: () => _onBoostTap(boost, Price.boost, false))),
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
                            SizedBox(width: 2.d),
                            SVG.show("coin", 18.d),
                            SkinnedText("$adyCost",
                                style: theme.textTheme.headline5)
                          ]),
                      onTap: () => _onBoostTap(boost, adyCost, true))),
              SizedBox(height: 6.d)
            ])));
  }

  void _onBoostTap(Pref boost, int cost, bool showAds) async {
    if (!showAds) {
      if (Pref.coin.value < cost) {
        Rout.push(context, Toast("coin_notenough".l(), icon: "coin"));
        return;
      }
    } else {
      var reward = await Ads.showRewarded(widget.mode.name);
      if (reward == null) return;
    }
    await Coins.change(-cost, "start", boost.name);

    if (boost == Pref.boostNext) MyGame.boostNextMode = 1;
    if (boost == Pref.boostBig) MyGame.boostBig = true;
    _onUpdate();
  }

  bool _has(Pref boost) {
    return (boost == Pref.boostNext)
        ? MyGame.boostNextMode > 0
        : MyGame.boostBig;
  }

  _onStart() async {
    _startButtonLabel = "wait_l".l();
    _onUpdate();
    await Analytics.updateVariantIDs();
    if (Pref.playCount.value > AdPlace.interstitialVideo.threshold) {
      await Ads.showInterstitial(AdPlace.interstitialVideo, widget.mode.name);
    }
    if (!mounted) return;
    var result = await Rout.push(context, const GamePage());
    MyGame.boostNextMode = 0;
    MyGame.boostBig = false;
    _startButtonLabel =
        (Prefs.getString("cells").isEmpty ? "start_l" : "continue_l").l();
    _onUpdate();
    if (mounted && result != null) {
      var accept = await Rout.push(
          context,
          Confirm(
              "Install the game on your device to make sure you’ll always have your progress saved and safe!",
              acceptText: "Install",
              declineText: "Not yet"));
      if (accept) {
        InstallPrompt.showInstallPrompt();
      } else if (mounted) {
        await Rout.push(context, RatingDialog());
      }
    }
  }

  _onUpdate() => setState(() {});

  Widget _questButton(ThemeData theme) {
    var completed = Quests.hasCompleted;
    var button = PunchButton(
        bottom: 112.d,
        right: -16.d,
        width: 140.d,
        height: 96.d,
        padding: EdgeInsets.fromLTRB(2.d, 12.d, 14.d, 6.d),
        colors: (completed ? TColors.green : TColors.purple).value,
        content: Column(children: [
          SVG.show("quests", 32.d),
          SizedBox(height: 12.d),
          SkinnedText("quests_l".l(), style: theme.textTheme.headline5)
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
        bottom: 112.d,
        left: -16.d,
        width: 140.d,
        height: 96.d,
        padding: EdgeInsets.fromLTRB(14.d, 6.d, 2.d, 6.d),
        colors: (available ? TColors.green : TColors.yellow).value,
        content: Column(children: [
          SVG.show("daily", 32.d),
          SizedBox(height: 12.d),
          SizedBox(
              width: 100.d,
              child: SkinnedText(
                "daily_l".l(),
                style: theme.textTheme.headline5,
                textAlign: TextAlign.center,
              ))
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
