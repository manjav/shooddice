import 'package:flutter/material.dart';
import 'package:project/dialogs/dialogs.dart';
import 'package:project/utils/localization.dart';
import 'package:project/utils/utils.dart';
import 'package:rive/rive.dart';

class QuitDialog extends AbstractDialog {
  final bool? showAvatar;
  QuitDialog({Key? key, this.showAvatar})
      : super(
          DialogMode.quit,
          key: key,
          height: 54.d,
          title: "quit_l".l(),
          statsButton: const SizedBox(),
          scoreButton: const SizedBox(),
          padding: EdgeInsets.fromLTRB(16.d, 4.d, 16.d, 8.d),
        );
  @override
  _QuitDialogState createState() => _QuitDialogState();
}

class _QuitDialogState extends AbstractDialogState<QuitDialog> {
  @override
  Widget coinsButtonFactory(ThemeData theme) => const SizedBox();

  @override
  Widget contentFactory(ThemeData theme) {
    return GestureDetector(
        child:
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Expanded(
              child:
                  Text("quit_message".l(), style: theme.textTheme.headline5)),
          SVG.show("accept", 28.d)
        ]),
        onTap: () => buttonsClick(context, "quit", 0, false));
  }

  @override
  Widget headerFactory(ThemeData theme, double width) {
    var showAvatar = widget.showAvatar ?? true;
    return Container(
        padding: EdgeInsets.only(left: 20.d),
        width: width,
        height: 120.d,
        child:
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Column(mainAxisAlignment: MainAxisAlignment.end, children: [
            Text(widget.title!, style: theme.textTheme.headline4),
            SizedBox(height: 22.d)
          ]),
          showAvatar
              ? SizedBox(
                  width: 120.d,
                  height: 120.d,
                  child: const RiveAnimation.asset('anims/nums-character.riv',
                      stateMachines: ["unhappyState"]))
              : const SizedBox()
        ]));
  }
}
