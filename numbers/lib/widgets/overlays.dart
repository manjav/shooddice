import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:numbers/utils/prefs.dart';
import 'package:numbers/utils/themes.dart';
import 'package:numbers/utils/utils.dart';
import 'package:numbers/widgets/buttons.dart';
import 'package:numbers/widgets/components.dart';

class Overlays {
  static Widget basic(BuildContext context,
      {Widget? content,
      double? width,
      double? height,
      String? title,
      bool hasClose = true}) {
    var theme = Theme.of(context);
    return Stack(alignment: Alignment.center, children: [
      Positioned(top: 50, right: 24, child: Components.scores(theme)),
      Positioned(top: 52, left: 24, child: Components.coins(theme)),
      Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Padding(
            padding: EdgeInsets.fromLTRB(48, 64, 48, 20),
            child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (title != null)
                    Text(title, style: theme.textTheme.bodyText2),
                  if (hasClose)
                    GestureDetector(
                        child: SVG.show("close", 28),
                        onTap: () => _buttonsClick(context, null, null))
                ])),
        Container(
            width: width ?? 300,
            height: height ?? 340,
            padding: EdgeInsets.fromLTRB(18, 12, 18, 28),
            decoration: BoxDecoration(
                color: theme.dialogTheme.backgroundColor,
                shape: BoxShape.rectangle,
                borderRadius: BorderRadius.all(Radius.circular(24))),
            child: content ?? SizedBox())
      ])
    ]);
  }
