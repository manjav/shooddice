import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:numbers/utils/ads.dart';
import 'package:numbers/utils/prefs.dart';
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
  String _message = "Please Wait...";
  static List<ProductDetails> coins = [];
  static List<ProductDetails> others = [];

  @override
  void initState() {
    _initShop();
    super.initState();
  }

  Future<void> _initShop() async {
    var available = await InAppPurchase.instance.isAvailable();
    if (!available) {
      setState(() => _message = "Shop is inavalable!");
      return;
    }
    if (coins.length > 0) {
      setState(() => _message = "");
      return;
    }

    Set<String> skus = {"noAds"};
    for (var i = 0; i < 6; i++) skus.add("coin_$i");
    var response = await InAppPurchase.instance.queryProductDetails(skus);
    if (response.notFoundIDs.isNotEmpty) {
      // Handle the error.
    }
    coins = [];
    for (var product in response.productDetails) {
      print(product.id);
      if (product.isConsumable)
        coins.add(product);
      else
        others.add(product);
    }
    setState(() => _message = "");
  }
  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    return Stack(children: [
      Overlays.basic(context,
        title: "Shop",
        scoreButton: SizedBox(),
        coinButton: Components.coins(context, clickable: false),
        padding: EdgeInsets.fromLTRB(6.d, 0, 6.d, 16.d),
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
                  children: List.generate(
                      coins.length, (i) => _itemBuilder(theme, coins[i])),
                )),
            Container(
                height: 76,
                padding: EdgeInsets.fromLTRB(10.d, 6.d, 10.d, 12.d),
                  decoration: CustomDecoration(
                      Themes.swatch[TColors.white]!, 12.d, true),
                child: Row(children: [
                  SizedBox(width: 8.d),
                  SVG.show("noads", 48),
                  SizedBox(width: 24.d),
                  Expanded(
                        child:
                            Text("No Ads", style: theme.textTheme.bodyText2)),
                  SizedBox(
                      width: 92.d,
                      height: 40.d,
                      child: Buttons.button(
                        cornerRadius: 8.d,
                        colors: Themes.swatch[TColors.green],
                        content: Center(
                              child: Text(
                                  "${others.length > 0 ? others[0].price : 0}",
                                style: theme.textTheme.headline5)),
                          onTap: () => _onShopItemTap(others[0]),
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
                            isEnable: Ads.isReady(),
                            colors: Themes.swatch[TColors.orange],
                            onTap: _freeCoin,
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
                            onTap: _restorePurchases,
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
          )),
      _overlay(theme)
    ]);
  }

  _overlay(ThemeData theme) {
    if (_message == "") return SizedBox();
    return Container(
        color: Themes.swatch[TColors.black]![0].withAlpha(230),
        alignment: Alignment.center,
        padding: EdgeInsets.all(16.d),
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Text(_message, style: theme.textTheme.headline4),
          SizedBox(height: 32.d),
          _message == "Please Wait..."
              ? CircularProgressIndicator()
              : TextButton(
                  onPressed: () {
                    if (_message == "Shop is inavalable!")
                      Navigator.of(context).pop();
                    else
                      setState(() => _message = "");
                  },
                  child: Text("OK"))
        ]));
  }

  Widget _itemBuilder(ThemeData theme, ProductDetails product) {
    return Container(
        height: 110.d,
        child: Buttons.button(
          onTap: () => _onShopItemTap(product),
          content: Column(children: [
            SizedBox(height: 7.d),
            Row(children: [
              SVG.show("coin", 20.d),
              Text(" ${product.name}", style: theme.textTheme.subtitle1)
            ]),
            SizedBox(height: 7.d),
            Container(
              width: 92.d,
              height: 40.d,
              decoration:
                  CustomDecoration(Themes.swatch[TColors.green]!, 8.d, true),
              child: Padding(
                  padding: EdgeInsets.fromLTRB(6.d, 6.d, 6.d, 7.d),
                  child: Text("${product.price}",
                      style: theme.textTheme.headline6,
                      textAlign: TextAlign.center)),
            ),
            SizedBox(height: 4.d)
          ]),
        ));
  }

  _onShopItemTap(ProductDetails product) {
    setState(() => _message = "Please Wait...");
    var purchaseParam = PurchaseParam(productDetails: product);
    if (product.isConsumable) {
      InAppPurchase.instance.buyConsumable(purchaseParam: purchaseParam);
    } else {
      InAppPurchase.instance.buyNonConsumable(purchaseParam: purchaseParam);
    }
  }

  _restorePurchases() async {
    await InAppPurchase.instance.restorePurchases();
    setState(() {});
  }

  _freeCoin() async {
    var complete = await Ads.show();
    if (complete) {
      Pref.coin.increase(100);
      setState(() {});
    }
  }
}

extension PExt on ProductDetails {
  String get name => title.split(' ')[0];
  int get amount => int.parse(name);
  bool get isConsumable => id.substring(0, 5) == "coin_";
}
