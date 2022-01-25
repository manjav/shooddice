import 'package:flutter/material.dart';
import 'package:project/dialogs/dialogs.dart';
import 'package:project/dialogs/shop.dart';
import 'package:project/dialogs/toast.dart';
import 'package:project/theme/themes.dart';
import 'package:project/utils/ads.dart';
import 'package:project/utils/localization.dart';
import 'package:project/utils/prefs.dart';
import 'package:project/utils/sounds.dart';
import 'package:project/utils/utils.dart';
import 'package:project/widgets/buttons.dart';

class Callout extends AbstractDialog {
  static double chromeWidth = 220.d;
  static double chromeHeight = 84.d;
  final String text;
  final String type;
  final bool? hasCoinButton;
  const Callout(this.text, this.type,
      {Key? key,
      EdgeInsets? padding,
      double? width,
      double? height,
      this.hasCoinButton})
      : super(
          DialogMode.callout,
          key: key,
          padding: padding,
          width: width,
          height: height,
        );
  @override
  _CalloutState createState() => _CalloutState();
}

class _CalloutState extends AbstractDialogState<Callout> {
  @override
  Widget build(BuildContext context) {
    var pd = widget.padding;
    var theme = Theme.of(context);
    var hasCoinButton = widget.hasCoinButton ?? true;
    var hasCoin = Pref.coin.value > Price.boost;
    Callout.chromeWidth = hasCoin ? 132.d : 220.d;
    Callout.chromeHeight = hasCoin ? 100.d : 84.d;
    Sound.play("pop");
    return Stack(children: [
      Positioned(
          left: pd != null && pd.left != 0 ? pd.left : null,
          top: pd != null && pd.top != 0 ? pd.top : null,
          right: pd != null && pd.right != 0 ? pd.right : null,
          bottom: pd != null && pd.bottom != 0 ? pd.bottom : null,
          child: Container(
              width: widget.width ?? Callout.chromeWidth,
              height: widget.height ?? Callout.chromeHeight,
              padding: EdgeInsets.all(8.d),
              decoration: BoxDecoration(
                  boxShadow: const [
                    BoxShadow(
                        blurRadius: 3,
                        color: Colors.black,
                        offset: Offset(0.5, 2))
                  ],
                  color: theme.cardColor,
                  shape: BoxShape.rectangle,
                  borderRadius: const BorderRadius.all(Radius.circular(16))),
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(widget.text, style: theme.textTheme.subtitle2),
                    Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                      SizedBox(
                          width: 98.d,
                          height: 44.d,
                          child: hasCoinButton
                              ? BumpedButton(
                                  cornerRadius: 12.d,
                                  colors: TColors.orange.value,
                                  content: Row(children: [
                                    SVG.show("coin", 24.d),
                                    Expanded(
                                        child: Text("${Price.boost}",
                                            textAlign: TextAlign.center,
                                            style: theme.textTheme.bodyText2))
                                  ]),
                                  onTap: () => buttonsClick(context,
                                      widget.type, -Price.boost, false))
                              : const SizedBox()),
                      SizedBox(width: hasCoin ? 0 : 8.d),
                      hasCoin
                          ? const SizedBox()
                          : SizedBox(
                              width: 98.d,
                              height: 44.d,
                              child: BumpedButton(
                                  cornerRadius: 12.d,
                                  isEnable: Ads.isReady(),
                                  colors: TColors.green.value,
                                  errorMessage: Toast("ads_unavailable".l(),
                                      monoIcon: "0"),
                                  content: Row(children: [
                                    SVG.icon("A", theme, scale: 0.7),
                                    Expanded(
                                        child: Text("free_l".l(),
                                            textAlign: TextAlign.center,
                                            style: theme.textTheme.headline5))
                                  ]),
                                  onTap: () => buttonsClick(
                                      context, widget.type, 0, true)))
                    ])
                  ])))
    ]);
  }
}
