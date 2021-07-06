import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:numbers/utils/prefs.dart';
import 'package:numbers/utils/utils.dart';
import 'package:numbers/widgets/buttons.dart';

class Components {
  static Widget scores(ThemeData theme) {
    return Hero(
        tag: "score",
        child: Row(children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(Prefs.score.format(), style: theme.textTheme.headline4),
              Text("${Pref.record.value.format()}",
                  style: theme.textTheme.headline5)
            ],
          ),
          SizedBox(width: 4),
          SVG.show("cup", 48),
        ]));
  }

  static Widget coins(ThemeData theme, {Function()? onTap}) {
    return Hero(
        tag: "coin",
        child: Buttons.button(
          content: Row(children: [
            SVG.show("coin", 32),
            Expanded(
                child: Text("${Pref.coin.value.format()}",
                    textAlign: TextAlign.center,
                    style: theme.textTheme.button)),
            Text("+  ",
                textAlign: TextAlign.center, style: theme.textTheme.button)
          ]),
          onTap: onTap ?? () {},
        ));
  }
}
