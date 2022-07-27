import 'dart:async';

import 'package:games_services/games_services.dart';
import 'package:project/utils/localization.dart';

import 'analytic.dart';

class Games {
  static Timer? _timer;

  static Future<void> signIn() async {
    await GamesServices.signIn();
  }

  static void submitScore(int score) {
    _timer?.cancel();
    _timer = Timer(const Duration(seconds: 5), () {
      _timer?.cancel();
      GamesServices.submitScore(
          score: Score(
              androidLeaderboardID: 'leaderboard_android'.l(),
              iOSLeaderboardID: 'leaderboard_ios'.l(),
              value: score));
    });
  }

  static bool showLeaderboards(String source) {
    Analytics.funnle("rankclicks");
    Analytics.design('guiClick:record:$source');
    GamesServices.showLeaderboards();
    return true;
  }
}
