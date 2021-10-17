import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:numbers/utils/localization.dart';
import 'package:numbers/utils/utils.dart';
import 'package:rive/rive.dart';

import 'dialogs.dart';

// ignore: must_be_immutable
class QuitDialog extends AbstractDialog {
  final bool? showAvatar;
  QuitDialog({this.showAvatar})
      : super(DialogMode.quit,
            height: 54.d,
            title: "quit_l".l(),
            showCloseButton: showAvatar ?? true,
            coinButton: SizedBox(),
            statsButton: SizedBox(),
            scoreButton: SizedBox(),
            padding: EdgeInsets.fromLTRB(16.d, 4.d, 16.d, 8.d));
  @override
  _QuitDialogState createState() => _QuitDialogState();
}

class _QuitDialogState extends AbstractDialogState<QuitDialog> {
  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    widget.closeButton = SizedBox(
        width: 100.d,
        height: 100.d,
        child: RiveAnimation.asset('anims/nums-character.riv',
            stateMachines: ["unhappy"]));
    widget.child = GestureDetector(
        child:
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Expanded(
              child:
                  Text("quit_message".l(), style: theme.textTheme.headline5)),
          SVG.show("accept", 28.d)
        ]),
        onTap: () => buttonsClick(context, "quit", 0));
    return super.build(context);
  }
}