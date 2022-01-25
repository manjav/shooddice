import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:http/http.dart' as http;
import 'package:in_app_review/in_app_review.dart';
import 'package:project/dialogs/dialogs.dart';
import 'package:project/dialogs/toast.dart';
import 'package:project/theme/themes.dart';
import 'package:project/utils/analytic.dart';
import 'package:project/utils/localization.dart';
import 'package:project/utils/prefs.dart';
import 'package:project/utils/utils.dart';
import 'package:project/widgets/buttons.dart';
import 'package:url_launcher/url_launcher.dart';

class RatingDialog extends AbstractDialog {
  static Future<bool> showRating(BuildContext context) async {
    debugPrint(
        "Rate:${Pref.rate.value}, plays:${Pref.playCount.value}, target:${Pref.rateTarget.value}");
    // Repeat rating request
    // Already 5 rating or pending to reach target play count
    if (Pref.rate.value >= 5 || Pref.playCount.value < Pref.rateTarget.value) {
      return false;
    }
    int rating = 0;
    try {
      rating = await Rout.push(context, RatingDialog());
    } catch (e) {
      return false;
    }
    Pref.rate.set(rating);
    Pref.rateTarget.increase(2);

    String comment = "";
    if (rating > 0) {
      if (rating < 5) {
        var r = await Rout.push(context, ReviewDialog());
        if (r != null) {
          comment = r;
          var url =
              "https://numbers.sarand.net/review/?rate=$rating&comment=$comment&visits=${Pref.visitCount.value}";
          var response = await http.get(Uri.parse(url));
          if (response.statusCode != 200) debugPrint('Failure status code 😱');
        }
      } else {
        await _requestReview();
      }
      await Rout.push(context, Toast("thanks_l".l()), barrierDismissible: true);
    }
    Analytics.design('rate', parameters: <String, dynamic>{
      'rating': rating,
      'visits': Pref.visitCount.value,
      'comment': comment
    });
    debugPrint(
        "Rating rate: ${Pref.rate.value} rating: $rating comment: $comment");
    return true;
  }

  // Send to store
  static Future<bool> _requestReview() async {
    if (Pref.rate.value != 5) return false;
    Pref.rate.set(6);
    // if (Configs.instance.buildConfig!.target == "cafebazaar") {
    //   if (Platform.isAndroid) {
    //     AndroidIntent intent = AndroidIntent(
    //         data: 'bazaar://details?id=com.gerantech.muslim.holy.quran',
    //         action: 'android.intent.action.EDIT',
    //         package: 'com.farsitel.bazaar');
    //     await intent.launch();
    //   }
    //   return;
    // }

    final InAppReview inAppReview = InAppReview.instance;
    if (await inAppReview.isAvailable()) {
      if (Pref.ratedBefore.value == 0) {
        inAppReview.requestReview();
        Pref.ratedBefore.set(1);
        return true;
      }
      inAppReview.openStoreListing();
    } else {
      var url = "app_url".l();
      await canLaunch(url) ? await launch(url) : throw 'Could not launch $url';
    }
    return true;
  }

  final int initialRating;
  RatingDialog({Key? key, this.initialRating = 1})
      : super(
          DialogMode.rating,
          key: key,
          height: 280.d,
          showCloseButton: false,
          title: "rate_title".l(),
          padding: EdgeInsets.fromLTRB(22.d, 18.d, 22.d, 22.d),
        );
  @override
  _RatingDialogState createState() => _RatingDialogState();
}

class _RatingDialogState extends AbstractDialogState<RatingDialog> {
  int _response = 0;
  @override
  Widget contentFactory(ThemeData theme) {
    return WillPopScope(
        onWillPop: () async => false,
        child: Stack(alignment: Alignment.topRight, children: <Widget>[
          Text("rate_message".l(),
              textAlign: TextAlign.justify, style: theme.textTheme.headline6),
          Center(
              child: RatingBar.builder(
                  initialRating: widget.initialRating.toDouble(),
                  itemSize: 36.d,
                  minRating: 1.0,
                  allowHalfRating: false,
                  glowColor: Colors.amber,
                  direction: Axis.horizontal,
                  itemCount: 5,
                  itemPadding: const EdgeInsets.symmetric(horizontal: 3.0),
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
                  errorMessage: Toast("rate_error".l(), icon: "ice"),
                  isEnable: _response > 0,
                  colors: TColors.blue.value,
                  content: Center(
                      child:
                          Text("rate_l".l(), style: theme.textTheme.headline5)),
                  onTap: () => Navigator.pop(context, _response)))
        ]));
  }
}

class ReviewDialog extends AbstractDialog {
  ReviewDialog({Key? key})
      : super(
          DialogMode.review,
          key: key,
          height: 0,
          width: 320.d,
          title: "review_l".l(),
          closeOnBack: false,
          padding: EdgeInsets.all(16.d),
        );
  @override
  _ReviewDialogState createState() => _ReviewDialogState();
}

class _ReviewDialogState extends AbstractDialogState<ReviewDialog> {
  final _commentController = TextEditingController();
  @override
  void initState() {
    super.initState();
    _commentController.addListener(() {
      setState(() {});
    });
  }

  @override
  Widget contentFactory(ThemeData theme) {
    return Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          TextField(
              autofocus: true,
              controller: _commentController,
              textInputAction: TextInputAction.newline,
              minLines: 1,
              maxLines: 5,
              style: theme.textTheme.headline6,
              decoration: InputDecoration(hintText: "review_hint".l())),
          const SizedBox(height: 15),
          BumpedButton(
              errorMessage: Toast("review_error".l(), icon: "ice"),
              isEnable: _commentController.text != "",
              colors: TColors.green.value,
              content: Center(
                  child: Text("send_l".l(), style: theme.textTheme.headline5)),
              onTap: () => Navigator.pop(context, _commentController.text))
        ]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: Center(child: super.build(context)));
  }
}
