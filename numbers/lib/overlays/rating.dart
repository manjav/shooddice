import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:numbers/main.dart';
import 'package:numbers/utils/prefs.dart';
import 'package:numbers/utils/themes.dart';
import 'package:numbers/utils/utils.dart';
import 'package:numbers/widgets/buttons.dart';

import 'all.dart';

class RateOverlay extends StatefulWidget {
  static showRating(BuildContext context) async {
    print(
        "Rating rate: ${Pref.rate.value}, playCount: ${Pref.playCount.value}, rateTarget: ${Pref.rateTarget.value}");
    // Send to store
    if (Pref.rate.value == 5) {
      return;
    }

    // Repeat rating request
    if (Pref.rate.value >= 5 || Pref.playCount.value < Pref.rateTarget.value)
      return; // Already 5 rating or pending to reach target play count
    int rating =
        await Rout.push(context, RateOverlay(), barrierDismissible: true);
    Pref.rate.set(rating);
    Pref.rateTarget.set(Pref.rateTarget.value + 10);

    String comment = "";
    if (rating > 0) {
    print("Rating rate: ${Pref.rate.value} rating: $rating comment: $comment");
  }

  final initialRating;
  RateOverlay({this.initialRating = 1});
  @override
  _RateOverlayState createState() => _RateOverlayState();
}

class _RateOverlayState extends State<RateOverlay> {
  int _response = 0;
  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    return WillPopScope(
        onWillPop: () async => false,
        child: Overlays.basic(context,
            height: 280.d,
            title: "Rate Us",
            padding: EdgeInsets.fromLTRB(22.d, 18.d, 22.d, 22.d),
            content: Stack(alignment: Alignment.topRight, children: <Widget>[
              Text(
                  "If you injoy playing, please take a moment to rate it.\n\nThanks for your support!",
                  textAlign: TextAlign.justify,
                  style: theme.textTheme.headline6),
              Center(
                  child: RatingBar.builder(
                      initialRating: widget.initialRating.toDouble(),
                      itemSize: 36,
                      minRating: 1.0,
                      allowHalfRating: false,
                      glowColor: Colors.amber,
                      direction: Axis.horizontal,
                      itemCount: 5,
                      itemPadding: EdgeInsets.symmetric(horizontal: 3.0),
                      onRatingUpdate: (rating) {
                        _response = rating.toInt();
                        setState(() {});
                      },
                      itemBuilder: (context, _) => Icon(Icons.star,
                          color: Colors.amber[_response == 0 ? 800 : 500]))),
              Positioned(
                  bottom: 12.d,
                  right: 48.d,
                  left: 48.d,
                  child: BumpedButton(
                      errorMessage: Center(
                          child: Text("First rate us !",
                              style: theme.textTheme.headline5)),
                      isEnable: _response > 0,
                      colors: TColors.blue.value,
                      content: Center(
                          child:
                              Text("Rate", style: theme.textTheme.headline5)),
                      onTap: () => Navigator.pop(context, _response)))
            ])));
  }
}
    }
