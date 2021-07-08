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
        padding: EdgeInsets.fromLTRB(8, 0, 8, 16),
        height: 460,
        content: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(
                height: 240,
                child: GridView.count(
                  crossAxisCount: 3,
                  crossAxisSpacing: 3,
                  mainAxisSpacing: 2,
                  childAspectRatio: 0.94,
                  children: List.generate(6, (i) => _itemBuilder(theme, i)),
                )),
            Container(
                height: 76,
                padding: EdgeInsets.fromLTRB(10, 6, 10, 12),
                decoration: CustomDecoration(Themes.swatch[TColors.white]!, 12),
                child: Row(children: [
                  SizedBox(width: 8),
                  SVG.show("noads", 36),
                  SizedBox(width: 16),
                  Expanded(
                      child: Text("No Ads", style: theme.textTheme.bodyText1)),
                  SizedBox(
                      width: 92,
                      height: 40,
                      child: Buttons.button(
                        cornerRadius: 8,
                        colors: Themes.swatch[TColors.green],
                        content: Center(
                            child: Text("\$1.99",
                                style: theme.textTheme.headline5)),
                        onTap: () {},
                      )),
                  SizedBox(height: 4)
                ])),
            Container(
                height: 44,
                alignment: Alignment.center,
                child: Container(
                    width: 48,
                    height: 7,
                    decoration: BoxDecoration(
                        color: Colors.grey,
                        shape: BoxShape.rectangle,
                        borderRadius: BorderRadius.all(Radius.circular(24))))),
            Container(
                height: 80,
                padding: EdgeInsets.symmetric(horizontal: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    SizedBox(
                        width: 120,
                        child: Buttons.button(
                            cornerRadius: 16,
                            colors: Themes.swatch[TColors.orange],
                            onTap: () => Navigator.of(context).pop("resume"),
                            content: Row(children: [
                              SVG.show("ads", 32),
                              SizedBox(width: 8),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text("Free",
                                      style: theme.textTheme.headline5),
                                  Row(
                                    children: [
                                      SVG.show("coin", 24),
                                      Text("+100",
                                          style: theme.textTheme.headline6)
                                    ],
                                  )
                                ],
                              )
                            ]))),
                    SizedBox(
                        width: 144,
                        child: Buttons.button(
                            onTap: () {},
                            colors: Themes.swatch[TColors.green],
                            cornerRadius: 16,
                            content: Row(children: [
                              SVG.show("reset", 32),
                              SizedBox(width: 12),
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
        height: 110,
        child: Buttons.button(
          onTap: () => _onShopItemTap(index),
          content: Column(children: [
            SizedBox(height: 4),
            Row(children: [
              SVG.show("coin", 26),
              Text("2100", style: theme.textTheme.bodyText1)
            ]),
            SizedBox(height: 8),
            Container(
              width: 92,
              height: 40,
              decoration: CustomDecoration(Themes.swatch[TColors.green]!, 8),
              child: Center(
                  child: Text("\$2.99", style: theme.textTheme.headline6)),
            ),
            SizedBox(height: 4)
          ]),
        ));
  }

  _onShopItemTap(int index) {
    print(index);
  }
}
