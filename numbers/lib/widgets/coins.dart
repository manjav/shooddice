import 'package:flutter/material.dart';
import 'package:numbers/dialogs/shop.dart';
import 'package:numbers/utils/analytic.dart';
import 'package:numbers/utils/prefs.dart';
import 'package:numbers/utils/utils.dart';
import 'package:numbers/widgets/buttons.dart';

class Coins extends StatefulWidget {
  final String source;
  final Function? onTap;
  final bool clickable;
  final double? left;
  final double? top;
  final double? height;

  Coins(this.source,
      {this.onTap, this.clickable = true, this.left, this.top, this.height});
  @override
  _CoinsState createState() => _CoinsState();
}

  static final _defaultTop = 32.d;
  static final _defaultLeft = 66.d;
  late double _height = widget.height ?? 52.d;

  @override
  Widget build(BuildContext context) {
    if (Pref.tutorMode.value == 0) return SizedBox();
    var theme = Theme.of(context);
    var text = "${Pref.coin.value.format()}";

    return Stack(alignment: Alignment.center, children: [
      Positioned(
          top: widget.top ?? _defaultTop,
          left: widget.left ?? _defaultLeft,
          height: _height - _punchController.value * 8.d,
          child: Hero(
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
                    if (widget.clickable) {
                      Analytics.design('guiClick:shop:${widget.source}');
                      if (widget.onTap != null)
                        widget.onTap?.call();
                else
                  Rout.push(context, ShopDialog());
              }
                  }))),
  }
}
