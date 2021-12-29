import 'dart:math';

import 'package:flutter/material.dart';
import 'package:numbers/utils/localization.dart';
import 'package:numbers/utils/prefs.dart';
import 'package:numbers/utils/themes.dart';
import 'package:numbers/utils/utils.dart';
import 'package:numbers/widgets/buttons.dart';
import 'package:numbers/widgets/components.dart';
import 'package:numbers/widgets/punchbutton.dart';

import 'dialogs.dart';

// ignore: must_be_immutable
class QuestsDialog extends AbstractDialog {
  QuestsDialog()
      : super(
          DialogMode.quests,
          width: 330.d,
          height: 360.d,
          title: "quests_l".l(),
        );
  @override
  _QuestsDialogState createState() => _QuestsDialogState();
}

class _QuestsDialogState extends AbstractDialogState<QuestsDialog> {
  @override
  Widget build(BuildContext context) {
    _updateQuests();
    var theme = Theme.of(context);

    widget.child = ListView.builder(
        // padding: const EdgeInsets.all(8),
        itemCount: _quests.length,
        itemBuilder: _questItemBuilder);

    return super.build(context);
  }

  Widget _questItemBuilder(BuildContext context, int index) {
    var quest = _quests[index];
    var theme = Theme.of(context);
    return Container(
        height: 72.d,
        child: BumpedButton(
            colors: TColors.whiteFlat.value,
            onTap: () => _onquestItemTap(quest),
            content:
                Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
              SVG.show("ice", 32.d),
              Expanded(
                  child: Column(children: [
                Text(quest.type.l(["${quest.max}"]),
                    style: theme.textTheme.subtitle1),
                SizedBox(
                    width: 132.d,
                    height: 32.d,
                    child: Components.slider(
                        theme, quest.min, quest.value, quest.max))
              ])),
              Column(children: [
                SVG.show("coin", 32.d),
                Text("x${quest.reward}", style: theme.textTheme.subtitle2)
              ])
            ])));
  }


class Quests {
  static Function(Quest)? onQuestComplete;
  static Map<QuestType, Quest> list = {};

  static void init() {
    _addQuest(QuestType.merges);
    _addQuest(QuestType.removeone);
    _addQuest(QuestType.video);
    _addQuest(QuestType.b2048);
  }

  static bool get hasCompleted {
    var quests = list.values;
    for (var quest in quests) if (quest.isDone) return true;
    return false;
    }

  static void _addQuest(QuestType type) {
    list[type] = Quest(type, type.level, value: type.value);
  }

  static void increase(QuestType type, int value) {
    if (value == 0) return;
    var quest = list[type];
    var key = "q_${type.name}";
    var res = Prefs.getInt(key) + value;
    Prefs.setInt(key, res, true);
    quest!.value = res;
    if (!quest.notified && res >= quest.max) {
      quest.notified = true;
      onQuestComplete?.call(quest);
    }
  }
}

class Quest {
  int value = 0;
  int level;
  final QuestType type;
  bool notified = false;

  Quest(this.type, this.level, {int value = 0}) {
    this.value = value;
  }

  bool get isDone => value >= max;

  String get text => ("quest_" + type.name).l([max.toString()]);

  void levelUp() {
    Prefs.setInt("q_l_${type.name}", level + 1, true);
    level++;
    notified = false;
  }

  int get max {
    return _getCheckpoint(type, level + 1);
  }

  int get min {
    if (level == 0) return 0;
    return _getCheckpoint(type, level);
  }

  static int _getCheckpoint(QuestType type, int stage) {
    switch (type) {
      case QuestType.b2048:
        return pow(2, stage + 1).toInt();
      case QuestType.merges:
        return pow(2, stage + 6).toInt();
      case QuestType.removeone:
        return pow(2, stage).toInt();
      case QuestType.video:
        return pow(2, stage).toInt();
    }
  }

  int get reward {
    switch (type) {
      case QuestType.b2048:
        return (level + 1) * 1000;
      case QuestType.merges:
        return (level + 1) * 500;
      case QuestType.removeone:
        return pow(2, level).toInt() * 200;
      case QuestType.video:
        return (level + 1) * 300;
    }
  }
}

enum QuestType { merges, removeone, video, b2048 }

extension QuestTypeExt on QuestType {
  String get name {
    switch (this) {
      case QuestType.b2048:
        return "b2048";
      case QuestType.merges:
        return "merges";
      case QuestType.removeone:
        return "removeone";
      case QuestType.video:
        return "video";
    }
  }

  String get icon {
    switch (this) {
      case QuestType.b2048:
        return "2048";
      case QuestType.merges:
        return "merge";
      case QuestType.removeone:
        return "remove-one";
      case QuestType.video:
        return "tv";
    }
  }

  int get value => Prefs.getInt("q_$name");
  int get level => Prefs.getInt("q_l_$name");
}

/*
Complete All Quests
*/
