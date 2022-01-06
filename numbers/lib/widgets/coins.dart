import 'package:flutter/material.dart';
import 'package:numbers/dialogs/shop.dart';
import 'package:numbers/utils/analytic.dart';
import 'package:numbers/utils/prefs.dart';
import 'package:numbers/utils/utils.dart';
import 'package:numbers/widgets/buttons.dart';

class Coins extends StatelessWidget {
  final String source;
  final Function? onTap;
  final bool clickable;

  Coins(this.source, {this.onTap, this.clickable = true});
  @override
  Widget build(BuildContext context) {
    if (Pref.tutorMode.value == 0) return SizedBox();
    var theme = Theme.of(context);
    var text = "${Pref.coin.value.format()}";
    return Hero(
        tag: "coin",
        child: BumpedButton(
            content: Row(children: [
              SVG.show("coin", 32.d),
              Expanded(
                  child: Text(text,
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyText2!
                          .copyWith(fontSize: text.length > 5 ? 17.d : 22.d))),
              clickable
                  ? Text("+  ",
                      textAlign: TextAlign.center,
                      style: theme.textTheme.button)
                  : SizedBox()
            ]),
            onTap: () {
              if (clickable) {
                Analytics.design('guiClick:shop:$source');
                if (onTap != null)
                  onTap?.call()();
                else
                  Rout.push(context, ShopDialog());
              }
            }));
  }
}
