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
  final String type;
  final int min;
  final int max;
  final int reward;
  int value;
  Quest(this.type, this.min, this.value, this.max, this.reward);
}

/*
Complete All Quests
*/
