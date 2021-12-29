import 'package:flutter/material.dart';
import 'package:numbers/utils/localization.dart';
import 'package:numbers/utils/themes.dart';
import 'package:numbers/utils/utils.dart';
import 'package:numbers/widgets/buttons.dart';
import 'package:numbers/widgets/components.dart';

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
  static List<Quest> _quests = <Quest>[];
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

  void _updateQuests() {
    if (_quests.isEmpty) {
      _quests.add(Quest("quest_merges", 0, 2, 10, 10));
      _quests.add(Quest("quest_powerup", 0, 4, 12, 12));
      _quests.add(Quest("quest_big", 0, 2, 6, 6));
      _quests.add(Quest("quest_ads", 0, 72, 100, 100));
    }
  }

  _onquestItemTap(Quest quest) {}
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
