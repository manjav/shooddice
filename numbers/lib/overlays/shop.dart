import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:numbers/utils/themes.dart';
import 'package:numbers/utils/utils.dart';
import 'package:numbers/widgets/buttons.dart';
import 'package:numbers/widgets/components.dart';

import 'all.dart';

class ShopOverlay extends StatefulWidget {
  ShopOverlay({Key? key}) : super(key: key);
  @override
  _ShopOverlayState createState() => _ShopOverlayState();
}

class _ShopOverlayState extends State<ShopOverlay> {
  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    return Overlays.basic(context,
        title: "Shop",
        scoreButton: SizedBox(),
        coinButton: Components.coins(context, clickable: false),
        padding: EdgeInsets.fromLTRB(8.d, 0, 8.d, 16.d),
        height: 460.d,
        content: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(
                height: 240.d,
                child: GridView.count(
                  crossAxisCount: 3,
                  crossAxisSpacing: 3.d,
                  mainAxisSpacing: 2.d,
                  childAspectRatio: 0.94,
                  children: List.generate(6, (i) => _itemBuilder(theme, i)),
                )),
            Container(
                height: 76,
                padding: EdgeInsets.fromLTRB(10.d, 6.d, 10.d, 12.d),
                decoration:
                    CustomDecoration(Themes.swatch[TColors.white]!, 12.d, true),
                child: Row(children: [
                  SizedBox(width: 8.d),
                  SVG.show("noads", 48),
                  SizedBox(width: 24.d),
                  Expanded(
                      child: Text("No Ads", style: theme.textTheme.bodyText2)),
                  SizedBox(
                      width: 92.d,
                      height: 40.d,
                      child: Buttons.button(
                        cornerRadius: 8.d,
                        colors: Themes.swatch[TColors.green],
                        content: Center(
                            child: Text("\$1.99",
                                style: theme.textTheme.headline5)),
                        onTap: () {},
                      )),
                  SizedBox(height: 4.d)
                ])),
            Container(
                height: 44.d,
                alignment: Alignment.center,
                child: Container(
                    width: 48.d,
                    height: 7.d,
                    decoration: BoxDecoration(
                        color: Colors.grey,
                        shape: BoxShape.rectangle,
                        borderRadius:
                            BorderRadius.all(Radius.circular(24.d))))),
            Container(
                height: 80.d,
                padding: EdgeInsets.symmetric(horizontal: 8.d),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    SizedBox(
                        width: 124.d,
                        child: Buttons.button(
                            cornerRadius: 16.d,
                            colors: Themes.swatch[TColors.orange],
                            onTap: () => Navigator.of(context).pop("resume"),
                            content: Row(children: [
                              SVG.icon("0", theme),
                              SizedBox(width: 8.d),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text("Free",
                                      style: theme.textTheme.headline5),
                                  Row(
                                    children: [
                                      SVG.show("coin", 24.d),
                                      Text("+100",
                                          style: theme.textTheme.headline6)
                                    ],
                                  )
                                ],
                              )
                            ]))),
                    SizedBox(
                        width: 140.d,
                        child: Buttons.button(
                            onTap: () {},
                            colors: Themes.swatch[TColors.green],
                            cornerRadius: 16.d,
                            content: Row(children: [
                              SVG.icon("5", theme),
                              SizedBox(width: 12.d),
                              Text("Restore\nPurchase",
                                  overflow: TextOverflow.ellipsis,
                                  style: theme.textTheme.headline6)
                            ]))),
                  ],
                ))
          ],
        ));
  }

  Widget _itemBuilder(ThemeData theme, int index) {
    return Container(
        height: 110.d,
        child: Buttons.button(
          onTap: () => _onShopItemTap(index),
          content: Column(children: [
            SizedBox(height: 4.d),
            Row(children: [
              SVG.show("coin", 22.d),
              Text(" 2100", style: theme.textTheme.bodyText2)
            ]),
            SizedBox(height: 7.d),
            Container(
              width: 92.d,
              height: 40.d,
              decoration: CustomDecoration(Themes.swatch[TColors.green]!, 8.d, true),
              child: Center(
                  child: Text("\$2.99", style: theme.textTheme.headline6)),
            ),
            SizedBox(height: 4.d)
          ]),
        ));
  }

  _onShopItemTap(int index) {
    print(index);
  }
}
